module Com = Shupdofi_com
module Datetime = Shupdofi_srv_datetime.Datetime

type absolute = Com.Directory.absolute Com.Directory.t
type relative = Com.Directory.relative Com.Directory.t

(* https://rosettacode.org/wiki/Walk_a_directory/Recursively#OCaml *)
let walk init f_file f_stop v =
  let rec walk acc l =
    match f_stop acc with
    | true -> acc
    | false ->
      match l with
      | [] -> acc
      | dir::tail ->
        let contents = Array.to_list (Sys.readdir dir) in
        let contents = List.rev_map (Filename.concat dir) contents in
        let dirs, files =
          List.fold_left (fun (dirs,files) f ->
              match (Unix.LargeFile.stat f).st_kind with
              | S_REG -> (dirs, f::files)
              | S_DIR -> (f::dirs, files)
              | _ -> (dirs, files)
            ) ([],[]) contents
        in
        let acc = List.fold_left f_file acc files in
        walk acc (dirs @ tail)
  in
  let pathname = Com.Directory.get_name v in
  walk init [pathname]

let make_from_list l =
  let name = String.concat (Filename.dir_sep) l in
  Com.Directory.make_relative ~name ()

let to_list_of_string v =
  let name = Com.Directory.get_name v in
  String.split_on_char (Filename.dir_sep).[0] name |> List.filter (fun e -> e <> "" && e <> ".")

let concat v1 v2 =
  let name = Filename.concat (Com.Directory.get_name v1) (Com.Directory.get_name v2) in
  Com.Directory.make_absolute ~name ()

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
  (*
  let l = List.map (fun name -> Com.Directory.make ~name ()) l in
  let subdirs_ok = List.for_all Com.Directory.is_defined l in
  let nb = List.length l in
  match subdirs_ok with
  | false -> None
  | true -> (
      let subdir = 
        match nb with
        | n when n < 1 -> None
        | n when n = 1 -> Some (List.hd l)
        | _ -> Some (List.fold_left (fun acc e -> concat acc e) (List.hd l) (List.tl l))
      in
      *)
  let subdir = make_from_list l in
  if (Com.Directory.is_defined subdir) then (
    try
      let pathdir = concat root subdir |> Com.Directory.get_name in
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
  let absolute_before = concat root_dir before in
  let absolute_after = concat root_dir after in
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
  let dir = concat root_dir v in
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

(* to check: find . -type f | xargs stat -c "%s" | awk '{s+=$1} END {print s}' *)
let size ~stop v =
  let f acc path =
    let stat = Unix.LargeFile.stat path in
    Int64.add acc (stat.Unix.LargeFile.st_size)
  in
  let f_stop v =
    v >= stop
  in
  walk 0L f f_stop v
