module Com = Shupdofi_com

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
    let new_dir = Directory.concat root_dir subdir in
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
    let new_dir = Directory.concat root_dir subdir in
    let v = Com.Path.make_absolute new_dir file in
    let name = to_string v in
    let oc = Out_channel.open_bin name in
    let write = Out_channel.output oc in
    let close () = Out_channel.close oc in
    write, close

let update_meta_infos root_dir v =
  let dir = Com.Path.get_directory v in
  let file = Com.Path.get_file v in
  match dir, file with
  | Some dir, Some file -> (
      let new_dir = Directory.concat root_dir dir in
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
      let absolute_before_dir = Directory.concat root_dir before_dir in
      let absolute_after_dir = Directory.concat root_dir after_dir in
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
      let new_dir = Directory.concat root_dir dir in
      let path_with_root = Com.Path.make_absolute new_dir file in
      let pathname = to_string path_with_root in
      Sys.remove pathname
    )
  | _, _ -> failwith "Empty directory or file in path"
