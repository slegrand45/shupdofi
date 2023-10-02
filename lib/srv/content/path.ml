module Com = Shupdofi_com
module Datetime = Shupdofi_srv_datetime.Datetime

type 'a t = 'a Com.Path.t

let to_string v =
  let directory = Option.fold ~some:Com.Directory.get_name ~none:"" (Com.Path.get_directory v) in
  let file = Option.fold ~some:Com.File.get_name ~none:"" (Com.Path.get_file v) in
  Filename.concat directory file

let absolute_from_string s =
  let dirname = Filename.dirname s in
  let filename = Filename.basename s in
  let directory = Com.Directory.make_absolute ~name:dirname () in
  let file = Com.File.make ~name:filename () in
  Com.Path.make_absolute directory file

let relative_from_string s =
  let dirname = Filename.dirname s in
  let filename = Filename.basename s in
  let directory = Com.Directory.make_relative ~name:dirname () in
  let file = Com.File.make ~name:filename () in
  Com.Path.make_relative directory file

let add_extension ext v =
  let file = Com.Path.get_file v in
  match file with
  | None -> v
  | Some x -> 
    let file = File.add_extension ext x in
    Com.Path.set_file file v

let retrieve_stat v =
  let s = to_string v in
  try
    let stat = Unix.LargeFile.stat s in
    Some stat
  with
  | _ -> None

let usable = function
  | None -> false
  | Some stat ->
    match stat.Unix.LargeFile.st_kind with
    | Unix.S_REG -> true
    | _ -> false

let mime v =
  Magic_mime.lookup (to_string v)

let next_if_exists root_dir v =
  let subdir = Com.Path.get_directory v in
  let file = Com.Path.get_file v in
  match subdir, file with
  | None, _ -> failwith "Empty directory in path"
  | _, None -> failwith "Empty file in path"
  | Some subdir, Some file -> 
    let new_dir = Directory.concat_absolute root_dir subdir in
    let v = Com.Path.make_absolute new_dir file in
    let name = to_string v in
    let rec f i name new_name =
      if Sys.file_exists new_name then
        let basename = Filename.basename name in
        let extension = Filename.extension basename in
        let name_without_extension = Filename.remove_extension basename in
        let new_name = Printf.sprintf "%s (%u)%s" name_without_extension i extension in
        f (i + 1) name (Filename.concat (Filename.dirname name) new_name)
      else
        new_name
    in
    let name = f 1 name name in
    Com.Path.make_relative subdir (Com.File.make ~name:(Filename.basename name) ())

let oc root_dir v =
  let subdir = Com.Path.get_directory v in
  let file = Com.Path.get_file v in
  match subdir, file with
  | None, _ -> failwith "Empty directory in path"
  | _, None -> failwith "Empty file in path"
  | Some subdir, Some file -> 
    let new_dir = Directory.concat_absolute root_dir subdir in
    let v = Com.Path.make_absolute new_dir file in
    let name = to_string v in
    let oc = Out_channel.open_bin name in
    let write = Out_channel.output oc in
    let close = (fun () -> Out_channel.close oc) in
    write, close

let update_meta_infos root_dir v =
  let dir = Com.Path.get_directory v in
  let file = Com.Path.get_file v in
  match dir, file with
  | Some dir, Some file -> (
      let new_dir = Directory.concat_absolute root_dir dir in
      let path_with_root = Com.Path.make_absolute new_dir file in
      let stat = retrieve_stat path_with_root in
      match stat with
      | None -> v
      | Some stat ->
        let size = stat.Unix.LargeFile.st_size in
        let mtime = stat.Unix.LargeFile.st_mtime |> Datetime.of_mtime in
        let new_file = Com.File.(set_size_bytes (Some size) file |> set_mdatetime (Some mtime)) in
        Com.Path.set_file new_file v
    )
  | _, _ -> failwith "Empty directory or file in path"

let rename root_dir ~before ~after =
  let before_dir = Com.Path.get_directory before in
  let before_file = Com.Path.get_file before in
  let after_dir = Com.Path.get_directory after in
  let after_file = Com.Path.get_file after in
  match before_dir, before_file, after_dir, after_file with
  | Some before_dir, Some before_file, Some after_dir, Some after_file -> (
      let absolute_before_dir = Directory.concat_absolute root_dir before_dir in
      let absolute_after_dir = Directory.concat_absolute root_dir after_dir in
      let before_path = Com.Path.make_absolute absolute_before_dir before_file in
      let after_path = Com.Path.make_absolute absolute_after_dir after_file in
      try
        if (Sys.file_exists (to_string after_path)) then
          None
        else (
          Sys.rename (to_string before_path) (to_string after_path);
          let after = update_meta_infos root_dir after in
          let after_file = Com.Path.get_file after in
          match after_file with
          | Some after_file -> Some (before_file, after_file)
          | _ -> None
        )
      with
      | _ -> None
    )
  | _ -> failwith "Empty directory or file in path"

let delete root_dir v =
  let dir = Com.Path.get_directory v in
  let file = Com.Path.get_file v in
  match dir, file with
  | Some dir, Some file -> (
      let new_dir = Directory.concat_absolute root_dir dir in
      let path_with_root = Com.Path.make_absolute new_dir file in
      let pathname = to_string path_with_root in
      Sys.remove pathname
    )
  | _, _ -> failwith "Empty directory or file in path"

(*
let file_copy ~paste_mode ~from_path ~to_path =
  if (from_path <> to_path) then (
    match paste_mode, Sys.file_exists to_path with
    | Com.Path.Paste_ignore, true ->
      ()
    | _, _ ->
      (* https://ocaml.github.io/ocamlunix/files.html#sec33 *)
      let buffer_size = 32768 in
      let buffer = Bytes.create buffer_size in
      let fd_in = Unix.openfile from_path [O_RDONLY] 0 in
      let fd_out = Unix.openfile to_path [O_WRONLY; O_CREAT; O_TRUNC] 0o600 in
      let rec copy_loop () = match Unix.read fd_in buffer 0 buffer_size with
        | 0 -> ()
        | r -> ignore (Unix.write fd_out buffer 0 r); copy_loop ()
      in
      copy_loop ();
      Unix.close fd_in;
      Unix.close fd_out
  )
*)

(*
let tree ~root ~subdir ~dir =
  let rec f (dirname, acc) e =
    let path = Com.Directory.get_name (Directory.concat_absolute root (Directory.make_from_list [Com.Directory.get_name subdir; dirname; e])) in
    let stat = Unix.LargeFile.stat path in
    match stat.Unix.LargeFile.st_kind with
    | Unix.S_REG ->
      let r = Com.Path.make_relative (Directory.make_from_list [dirname]) (Com.File.make ~name:e ()) in
      (dirname, r :: acc)
    | Unix.S_DIR ->
      let v = Directory.make_from_list [Com.Directory.get_name subdir; dirname; e] in
      let dir = Directory.concat_absolute root v in
      let l = Sys.readdir (Com.Directory.get_name dir) |> Array.to_list in
      let (_, r) = List.fold_left f ((*Com.Directory.get_name v*) Com.Directory.get_name (Directory.make_from_list [dirname; e]), []) l in
      (Com.Directory.get_name (Directory.make_from_list [Com.Directory.get_name subdir; dirname]), r @ acc)
    | _ ->
      (dirname, acc)
  in
  let (_, tree) = List.fold_left f ("", []) [Com.Directory.get_name dir] in
  let l = List.sort_uniq compare tree in
  l
*)

(*
let size_of_tree ~tree ~root ~subdir =
  let f acc subpath =
    let dir_subpath = Com.Path.get_directory subpath in
    let name_dir_subpath = Option.fold ~none:"" ~some:(fun e -> Com.Directory.get_name e) dir_subpath in
    match Com.Path.get_file subpath with
    | Some file_subpath -> (
        let dir = Directory.concat_absolute root (Directory.make_from_list [Com.Directory.get_name subdir; name_dir_subpath]) in
        let path = Com.Path.make_absolute dir file_subpath in
        try
          let stat = retrieve_stat path in
          match stat with
          | None ->
            acc
          | Some stat ->
            let size = stat.Unix.LargeFile.st_size in
            Int64.add acc size
        with
        | _ ->
          acc
      )
    | None ->
      acc
  in
  List.fold_left f Int64.zero tree
*)

(*
let subpath_for_copy ~paste_mode root_dir v =
  let open Com.Path in
  match paste_mode with
  | Paste_ignore | Paste_overwrite -> v
  | Paste_rename -> next_if_exists root_dir v

let search_dir_created ~dir_created ~dir =
  let f acc e =
    match e with
    | Result.Error _ -> acc
    | Result.Ok (from_dir, to_dir) ->
      if (Com.Directory.get_name from_dir) = (Com.Directory.get_name dir) then
        match to_dir with
        | None -> from_dir :: acc
        | Some d -> d :: acc
      else
        acc
  in
  match List.fold_left f [] dir_created with
  | [] -> Com.Directory.make_relative ~name:"" ()
  | [v] -> v
  | _ -> Com.Directory.make_relative ~name:"" ()
*)

(*
let copy_from_tree ~paste_mode ~tree ~dir_created ~from_root ~from_subdir ~to_root ~to_subdir =
  let f subpath =
    let dir_subpath = Com.Path.get_directory subpath |> Option.get in
    let from_subdir = Directory.concat_relative from_subdir dir_subpath in
    let from_dir = Directory.concat_absolute from_root from_subdir in
    let new_dir_subpath = search_dir_created ~dir_created ~dir:dir_subpath in
    let to_subdir = Directory.concat_relative to_subdir new_dir_subpath in
    let to_dir = Directory.concat_absolute to_root to_subdir in
    match Com.Path.get_file subpath with
    | Some file_subpath -> (
        let from_path = Com.Path.make_absolute from_dir file_subpath in
        let to_subpath = subpath_for_copy ~paste_mode from_root (Com.Path.make_relative to_subdir file_subpath) in
        let to_path = Com.Path.make_absolute to_dir (Com.Path.get_file to_subpath |> Option.get) in
        try
          file_copy ~paste_mode ~from_path:(to_string from_path) ~to_path:(to_string to_path);
          let stat = retrieve_stat to_path in
          match stat with
          | None -> Result.error subpath
          | Some stat ->
            let size = stat.Unix.LargeFile.st_size in
            let mtime = stat.Unix.LargeFile.st_mtime |> Datetime.of_mtime in
            let new_file = Com.Path.get_file to_subpath |> Option.get |> Com.File.set_size_bytes (Some size) |> Com.File.set_mdatetime (Some mtime) in
            let to_subpath = Com.Path.set_file new_file to_subpath in
            Result.ok (Com.Path.set_directory from_subdir subpath, Some to_subpath)
        with
        | _ ->
          Result.error (Com.Path.set_directory from_subdir subpath)
      )
    | None ->
      Result.error (Com.Path.set_directory from_subdir subpath)
  in
  List.map f tree
  *)