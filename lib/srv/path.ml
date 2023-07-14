module Com = Shupdofi_com

type t = Com.Path.t

let to_string v =
  let directory = Option.fold ~some:Com.Directory.get_name ~none:"" (Com.Path.get_directory v) in
  let file = Option.fold ~some:Com.File.get_name ~none:"" (Com.Path.get_file v) in
  Filename.concat directory file

let from_string s =
  let dirname = Filename.dirname s in
  let filename = Filename.basename s in
  let directory = Com.Directory.make ~name:dirname () in
  let file = Com.File.make ~name:filename () in
  Com.Path.make directory file

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

let oc root_dir v =
  let dir = Com.Path.get_directory v in
  match dir with
  | None -> failwith "Empty directory in path"
  | Some dir -> 
    let new_dir = Directory.concat root_dir dir in
    let v = Com.Path.set_directory new_dir v in
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
      let path_with_root = Com.Path.make new_dir file in
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

let delete root_dir v =
  let dir = Com.Path.get_directory v in
  let file = Com.Path.get_file v in
  match dir, file with
  | Some dir, Some file -> (
      let new_dir = Directory.concat root_dir dir in
      let path_with_root = Com.Path.make new_dir file in
      let pathname = to_string path_with_root in
      Sys.remove pathname
    )
  | _, _ -> failwith "Empty directory or file in path"
