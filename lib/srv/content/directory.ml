module Com = Shupdofi_com
module Datetime = Shupdofi_srv_datetime.Datetime

type absolute = Com.Directory.absolute Com.Directory.t
type relative = Com.Directory.relative Com.Directory.t

(* https://rosettacode.org/wiki/Walk_a_directory/Recursively#OCaml *)
let walk init f_dir f_file f_stop v =
  let rec walk (acc_dir, acc_file) l =
    match f_stop acc_file with
    | true -> (acc_dir, acc_file)
    | false ->
      match l with
      | [] -> (acc_dir, acc_file)
      | dir::tail ->
        let contents = Array.to_list (Sys.readdir dir) in
        let contents = List.rev_map (Filename.concat dir) contents in
        let dirs, files =
          List.fold_left (fun (dirs,files) entry ->
              match (Unix.LargeFile.stat entry).st_kind with
              | S_REG -> (dirs, entry::files)
              | S_DIR -> (entry::dirs, files)
              | _ -> (dirs, files)
            ) ([],[]) contents
        in
        let acc_dir = List.fold_left f_dir acc_dir dirs in
        let acc_file = List.fold_left f_file acc_file files in
        walk (acc_dir, acc_file) (dirs @ tail)
  in
  let pathname = Com.Directory.get_name v in
  walk init [pathname]

let make_from_list l =
  (* remove empty string to avoid multiple dir_sep, like "//" *)
  let l = List.filter (fun s -> s <> "") l in
  let name = String.concat (Filename.dir_sep) l in
  Com.Directory.make_relative ~name ()

let to_list_of_string v =
  let name = Com.Directory.get_name v in
  String.split_on_char (Filename.dir_sep).[0] name |> List.filter (fun e -> e <> "" && e <> Filename.current_dir_name)

let concat_absolute v1 v2 =
  let name =
    match Com.Directory.get_name v1, Com.Directory.get_name v2 with
    | "", "" -> ""
    | "", s2 -> s2
    | s1, "" -> s1
    | s1, s2 -> Filename.concat s1 s2
  in
  Com.Directory.make_absolute ~name ()

let concat_relative v1 v2 =
  let name =
    match Com.Directory.get_name v1, Com.Directory.get_name v2 with
    | "", "" -> ""
    | "", s2 -> s2
    | s1, "" -> s1
    | s1, s2 -> Filename.concat s1 s2
  in
  Com.Directory.make_relative ~name ()

let is_usable v =
  let dirname = Com.Directory.get_name v in
  try
    let stat = Unix.LargeFile.stat dirname in
    match stat.Unix.LargeFile.st_kind with
    | Unix.S_DIR -> true
    | _ -> false
  with
  | _ -> false

let mkdir root l =
  let subdir = make_from_list l in
  if (Com.Directory.is_defined subdir) then (
    try
      let pathdir = concat_absolute root subdir |> Com.Directory.get_name in
      let () = Sys.mkdir pathdir 0o755 in
      let stat = Unix.LargeFile.stat pathdir in
      let mtime = stat.Unix.LargeFile.st_mtime |> Datetime.of_mtime in
      (* return only last dir of list *)
      let dir = List.rev l |> List.hd |> (fun v -> Com.Directory.make_relative ~name:v ()) in
      Some (Com.Directory.set_mdatetime (Some mtime) dir)
    with
    | _ -> None
  ) else
    None

let attach_stat root entry =
  let path = Filename.concat root entry in
  try
    let stat = Unix.LargeFile.stat path in
    (entry, Some stat)
  with
  | _ -> (entry, None)

let retrieve_mdatetime f (entry, stat) =
  match stat with
  | None -> (entry, stat)
  | Some stat -> 
    let mtime = stat.Unix.LargeFile.st_mtime in
    (f (Some (Datetime.of_mtime mtime)) entry, Some stat)

let read directory =
  let root = Com.Directory.get_name directory in
  let filter_kind st_kind (_, stat) =
    match stat with
    | None -> false
    | Some stat -> 
      match stat.Unix.LargeFile.st_kind with
      | v when v = st_kind -> true
      | _ -> false
  in
  let retrieve_size_bytes (file, stat) =
    match stat with
    | None -> (file, stat)
    | Some stat -> 
      let size = stat.Unix.LargeFile.st_size in
      (Com.File.set_size_bytes (Some size) file, Some stat)
  in
  try
    let l = Sys.readdir root |> Array.to_list |> List.map (attach_stat root) in
    let directories = List.filter (filter_kind Unix.S_DIR) l
                      |> List.map (fun (entry, stat) -> (Com.Directory.make_relative ~name:entry (), stat))
                      |> List.map (retrieve_mdatetime Com.Directory.set_mdatetime)
                      |> List.map fst
    in
    let files = List.filter (filter_kind Unix.S_REG) l
                |> List.map (fun (entry, stat) -> (Com.File.make ~name:entry (), stat))
                |> List.map retrieve_size_bytes
                |> List.map (retrieve_mdatetime Com.File.set_mdatetime)
                |> List.map fst
    in (directories, files)
  with
  | _ -> ([], [])

let rename root_dir ~before ~after =
  let absolute_before = concat_absolute root_dir before in
  let absolute_after = concat_absolute root_dir after in
  try
    if (Sys.file_exists (Com.Directory.get_name absolute_after)) then
      None
    else (
      Sys.rename (Com.Directory.get_name absolute_before) (Com.Directory.get_name absolute_after);
      let (_, stat) = attach_stat (Com.Directory.get_name root_dir) (Com.Directory.get_name after) in
      stat
    )
  with
  | _ -> None

let delete root_dir v =
  let dir = concat_absolute root_dir v in
  let pathname = Com.Directory.get_name dir in
  (* https://stackoverflow.com/a/56344603 *)
  let rec rmrf path = match Sys.is_directory path with
    | true ->
      Sys.readdir path |>
      Array.iter (fun name -> rmrf (Filename.concat path name));
      Sys.rmdir path
    | false -> Sys.remove path
  in
  try
    rmrf pathname
  with
  | _ -> failwith (Printf.sprintf "Unable to delete directory %s" (Com.Directory.get_name v))

(*
let tree ~root ~subdir ~dir =
  let rec f (dirname, acc) e =
    let path = Com.Directory.(get_name (concat_absolute root (make_from_list [get_name subdir; dirname; e]))) in
    match Sys.is_directory path with
    | true ->
      let v = make_from_list [dirname; e] in
      let acc = v :: acc in
      let l = Sys.readdir path |> Array.to_list in
      let (_, r) = List.fold_left f ((*Com.Directory.get_name v*) Com.Directory.get_name (make_from_list [dirname; e]), [v]) l in
      (Com.Directory.(get_name (make_from_list [get_name subdir; dirname])), r @ acc)
    | false ->
      (dirname, acc)
  in
  let (_, tree) = List.fold_left f ("", []) [Com.Directory.get_name dir] in
  List.sort_uniq compare tree
*)

let next_if_exists root_dir v =
  let rec f i v =
    let dir = concat_absolute root_dir v in
    let name = Com.Directory.get_name dir in
    if Sys.file_exists name then
      let new_name = Printf.sprintf "%s (%u)" (Filename.basename name) i in
      let l = to_list_of_string v |> List.rev |> List.tl |> List.cons new_name |> List.rev in
      let new_v = Com.Directory.make_relative ~name:(String.concat Filename.dir_sep l) () in
      f (i + 1) new_v
    else
      v
  in
  f 1 v

(*
let subdir_for_create ~paste_mode root_dir v =
  let open Com.Path in
  match paste_mode with
  | Paste_ignore | Paste_overwrite -> v
  | Paste_rename -> next_if_exists root_dir v

let search_in_created ~l ~dir =
  let dir_name = Com.Directory.get_name dir in
  let length_dir_name = String.length dir_name in
  let f acc e =
    match e with
    | Result.Error _ ->
      acc
    | Result.Ok (from_dir, to_dir) ->
      match to_dir with
      | None -> acc
      | Some to_dir ->
        (* si début de dir = from_dir_name*)
        let from_dir_name = Com.Directory.get_name from_dir in
        let string_to_match = from_dir_name ^ (Filename.dir_sep) in
        let length_string_to_match = String.length string_to_match in
        match length_dir_name >= length_string_to_match with
        | true ->
          if String.sub dir_name 0 length_string_to_match = string_to_match then (
            let new_name = (Com.Directory.get_name to_dir) ^ Filename.dir_sep ^
                           (String.sub dir_name length_string_to_match (length_dir_name - length_string_to_match))
            in
            (Com.Directory.make_relative ~name:new_name ()) :: acc
          )
          else (
            acc
          )
        | false -> acc
  in
  match List.fold_left f [] l with
  | [] -> dir
  | [v] -> v
  | _ -> dir
*)

(*
let create_from_tree ~paste_mode ~tree ~root ~subdir =
  let f acc dir =
    let dir = search_in_created ~l:acc ~dir in
    let subdir = concat_relative subdir dir in
    let new_subdir = subdir_for_create ~paste_mode root subdir in
    let path = concat_absolute root new_subdir |> Com.Directory.get_name in
    let () = try Sys.mkdir path 0o755 with | _ -> () in
    if not (Sys.file_exists path) || not (Sys.is_directory path) then
      (Result.error dir) :: acc
    else
      let (_, stat) = attach_stat (Com.Directory.get_name root) (Com.Directory.get_name new_subdir) in
      let new_subdir = retrieve_mdatetime Com.Directory.set_mdatetime (new_subdir, stat) |> fst in
      (Result.ok (dir, Some new_subdir)) :: acc
  in
  List.fold_left f [] tree
*)

(* to check: find . -type f | xargs stat -c "%s" | awk '{s+=$1} END {print s}' *)
let size ~stop v =
  let f_file acc path =
    let stat = Unix.LargeFile.stat path in
    Int64.add acc (stat.Unix.LargeFile.st_size)
  in
  let f_stop v =
    v >= stop
  in
  walk (0, 0L) (fun _ _ -> 0) f_file f_stop v |> snd

let absolute_subdirs root_dir l =
  let f_dir acc dir =
    dir :: acc
  in
  let f acc e =
    let dir = concat_absolute root_dir e in
    ((walk ([], 0) f_dir (fun _ _ -> 0) (fun _ -> false) dir) |> fst) @ acc
  in
  List.fold_left f [] l |> List.map (fun name -> Com.Directory.make_absolute ~name ())