module Com = Shupdofi_com
module Datetime = Shupdofi_srv_datetime.Datetime

type presence =
    Not_existing | Existing

type create =
    Same_name | New_name

type action =
  | Create of create
  | Untouch
  | Replace

type event =
  (presence * action)

type result_directory_ok = {
  from_dir_absolute : Com.Directory.absolute Com.Directory.t;
  to_dir_absolute : Com.Directory.absolute Com.Directory.t;
  from_dir_relative : Com.Directory.relative Com.Directory.t;
  to_dir_relative : Com.Directory.relative Com.Directory.t;
  event : event; [@warning "-69"]
}

type result_directory_error = {
  from_dir_absolute : Com.Directory.absolute Com.Directory.t; [@warning "-69"]
  to_dir_absolute : Com.Directory.absolute Com.Directory.t; [@warning "-69"]
  from_dir_relative : Com.Directory.relative Com.Directory.t;
  to_dir_relative : Com.Directory.relative Com.Directory.t;
  msg : string;
}

type result_file_ok = {
  from_file_absolute : Com.Directory.absolute Com.Path.t;
  to_file_absolute : Com.Directory.absolute Com.Path.t;
  from_file_relative : Com.Directory.relative Com.Path.t;
  to_file_relative : Com.Directory.relative Com.Path.t;
  event : event; [@warning "-69"]
}

type result_file_error = {
  from_file_absolute : Com.Directory.absolute Com.Path.t; [@warning "-69"]
  to_file_absolute : Com.Directory.absolute Com.Path.t; [@warning "-69"]
  from_file_relative : Com.Directory.relative Com.Path.t;
  to_file_relative : Com.Directory.relative Com.Path.t;
  msg : string;
}

type t = {
  directories_ok : result_directory_ok list;
  directories_error : result_directory_error list;
  files_ok : result_file_ok list;
  files_error : result_file_error list;
}

let result_empty = {
  directories_ok = [];
  directories_error = [];
  files_ok = [];
  files_error = [];
}

let result_add_ok_dir ~r ~event ~from_absolute ~to_absolute ~from_relative ~to_relative =
  let open Com.Directory in
  let from_dir_absolute = make_absolute ~name:from_absolute () in
  let to_dir_absolute = make_absolute ~name:to_absolute () in
  let from_dir_relative = make_relative ~name:from_relative () in
  let to_dir_relative = make_relative ~name:to_relative () in
  { r with directories_ok = { from_dir_absolute; to_dir_absolute; from_dir_relative; to_dir_relative; event } :: r.directories_ok }

let result_add_error_dir ~r ~from_absolute ~to_absolute ~from_relative ~to_relative ~msg =
  let open Com.Directory in
  let from_dir_absolute = make_absolute ~name:from_absolute () in
  let to_dir_absolute = make_absolute ~name:to_absolute () in
  let from_dir_relative = make_relative ~name:from_relative () in
  let to_dir_relative = make_relative ~name:to_relative () in
  { r with directories_error = { from_dir_absolute; to_dir_absolute; from_dir_relative; to_dir_relative; msg } :: r.directories_error }

let result_add_ok_file ~r ~event ~from_absolute ~to_absolute ~from_relative ~to_relative =
  let dir = Com.Directory.make_absolute ~name:(Filename.dirname from_absolute) () in
  let file = Com.File.make ~name:(Filename.basename from_absolute) () in
  let from_file_absolute = Com.Path.make_absolute dir file in
  let dir = Com.Directory.make_absolute ~name:(Filename.dirname to_absolute) () in
  let file = Com.File.make ~name:(Filename.basename to_absolute) () in
  let to_file_absolute = Com.Path.make_absolute dir file in
  let dir = Com.Directory.make_relative ~name:(Filename.dirname from_relative) () in
  let file = Com.File.make ~name:(Filename.basename from_relative) () in
  let from_file_relative = Com.Path.make_relative dir file in
  let dir = Com.Directory.make_relative ~name:(Filename.dirname to_relative) () in
  let file = Com.File.make ~name:(Filename.basename to_relative) () in
  let to_file_relative = Com.Path.make_relative dir file in
  { r with files_ok = { from_file_absolute; to_file_absolute; from_file_relative; to_file_relative; event } :: r.files_ok }

let result_add_error_file ~r ~from_absolute ~to_absolute ~from_relative ~to_relative ~msg =
  let dir = Com.Directory.make_absolute ~name:(Filename.dirname from_absolute) () in
  let file = Com.File.make ~name:(Filename.basename from_absolute) () in
  let from_file_absolute = Com.Path.make_absolute dir file in
  let dir = Com.Directory.make_absolute ~name:(Filename.dirname to_absolute) () in
  let file = Com.File.make ~name:(Filename.basename to_absolute) () in
  let to_file_absolute = Com.Path.make_absolute dir file in
  let dir = Com.Directory.make_relative ~name:(Filename.dirname from_relative) () in
  let file = Com.File.make ~name:(Filename.basename from_relative) () in
  let from_file_relative = Com.Path.make_relative dir file in
  let dir = Com.Directory.make_relative ~name:(Filename.dirname to_relative) () in
  let file = Com.File.make ~name:(Filename.basename to_relative) () in
  let to_file_relative = Com.Path.make_relative dir file in
  { r with files_error = { from_file_absolute; to_file_absolute; from_file_relative; to_file_relative; msg } :: r.files_error }

let selection_size ~root ~subdir ~dirs ~files =
  let root_dir = Directory.concat_absolute root subdir in
  let f_dir acc dir =
    Int64.add acc (Directory.size ~stop:Int64.max_int (Directory.concat_absolute root_dir dir))
  in
  let f_file acc file =
    let path = Com.Path.make_absolute root_dir file in
    try
      match Path.retrieve_stat path with
      | None -> acc
      | Some stat -> Int64.add acc (stat.Unix.LargeFile.st_size)
    with
    | _ -> acc
  in
  let size_dirs = List.fold_left f_dir Int64.zero dirs in
  let size_files = List.fold_left f_file Int64.zero files in
  Int64.add size_dirs size_files

let next_if_exists entry =
  let open Filename in
  let rec f i v =
    if Sys.file_exists v then
      let basename = basename v in
      let extension = extension basename in
      let name_without_extension = remove_extension basename in
      let new_name = Printf.sprintf "%s (%u)%s" name_without_extension i extension in
      f (i + 1) (concat (dirname v) new_name)
    else
      v
  in
  f 1 entry

let apply_paste_mode ~paste_mode entry =
  let open Com.Path in
  match paste_mode with
  | Paste_ignore | Paste_overwrite ->
    (Same_name, entry)
  | Paste_rename ->
    let new_entry = next_if_exists entry in
    if (new_entry = entry) then (Same_name, new_entry) else (New_name, new_entry)

let copy_file ~from_absolute ~to_absolute =
  if (from_absolute <> to_absolute) then (
    let buffer_size = 32768 in
    let buffer = Bytes.create buffer_size in
    let fd_in = Unix.openfile from_absolute [O_RDONLY] 0 in
    let fd_out = Unix.openfile to_absolute [O_WRONLY; O_CREAT; O_TRUNC] 0o600 in
    let rec copy_loop () = match Unix.read fd_in buffer 0 buffer_size with
      | 0 -> ()
      | r -> ignore (Unix.write fd_out buffer 0 r); copy_loop ()
    in
    copy_loop ();
    Unix.close fd_in;
    Unix.close fd_out
  )

let move_file ~from_absolute ~to_absolute =
  if (from_absolute <> to_absolute) then (
    Sys.rename from_absolute to_absolute
  )

let make_event paste_mode to_presence to_creation = 
  match to_presence, to_creation with
  | Not_existing, Same_name -> (to_presence, Create Same_name)
  | Existing, New_name -> (to_presence, Create New_name)
  | Existing, Same_name -> (
      let open Com.Path in
      match paste_mode with
      | Paste_ignore -> (to_presence, Untouch)
      | Paste_overwrite -> (to_presence, Replace)
      | Paste_rename -> assert false
    )
  | _, _ -> assert false

let rec action_on_entry ~action ~acc ~from_root ~to_root ~paste_mode ~from_entry ~to_subdir =
  let from_absolute = Filename.concat from_root from_entry in
  match Sys.is_directory from_absolute with
  | true -> (
      let to_absolute = Filename.concat to_root (Filename.concat to_subdir (Filename.basename from_entry)) in
      let to_presence =
        if Sys.file_exists to_absolute && Sys.is_directory to_absolute then Existing else Not_existing
      in
      let (to_creation, to_absolute) = apply_paste_mode ~paste_mode to_absolute in
      let to_relative = Filename.concat to_subdir (Filename.basename to_absolute) in
      let event = make_event paste_mode to_presence to_creation in
      if (from_absolute <> to_absolute) then
        try
          let () = try Sys.mkdir to_absolute 0o755 with | _ -> () in
          if (Sys.file_exists to_absolute) && (Sys.is_directory to_absolute) then (
            let entries = Array.to_list (Sys.readdir from_absolute) in
            let acc = List.fold_left
                (fun acc entry ->
                   let from_entry = Filename.concat from_entry entry in
                   let to_subdir = Filename.concat to_subdir (Filename.basename to_absolute) in
                   action_on_entry ~action ~acc ~from_root ~to_root ~paste_mode ~from_entry ~to_subdir)
                acc entries
            in
            result_add_ok_dir ~r:acc ~event ~from_absolute ~to_absolute ~from_relative:from_entry ~to_relative
          ) else (
            result_add_error_dir ~r:acc ~from_absolute ~to_absolute ~msg:"" ~from_relative:from_entry ~to_relative
          )
        with
        | exc ->
          result_add_error_dir ~r:acc ~from_absolute ~to_absolute ~msg:(Printexc.to_string exc) ~from_relative:from_entry ~to_relative
      else
        result_add_ok_dir ~r:acc ~event ~from_absolute ~to_absolute ~from_relative:from_entry ~to_relative
    )
  | false ->
    match Sys.is_regular_file from_absolute with
    | true -> (
        let to_absolute = Filename.concat to_root (Filename.concat to_subdir (Filename.basename from_entry)) in
        let to_presence =
          if Sys.file_exists to_absolute && Sys.is_regular_file to_absolute then Existing else Not_existing
        in
        let (to_creation, to_absolute) = apply_paste_mode ~paste_mode to_absolute in
        let to_relative = Filename.concat to_subdir (Filename.basename to_absolute) in
        let event = make_event paste_mode to_presence to_creation in
        if (from_absolute <> to_absolute) then (
          try
            let to_exists = Sys.file_exists to_absolute && Sys.is_regular_file to_absolute in
            let () =
              let f_action =
                match action with
                | Com.Path.Copy -> copy_file
                | Com.Path.Move -> move_file
              in
              match paste_mode with
              | Com.Path.Paste_overwrite ->
                f_action ~from_absolute ~to_absolute;
              | Com.Path.Paste_ignore ->
                if (not to_exists) then f_action ~from_absolute ~to_absolute else ();
              | Com.Path.Paste_rename ->
                if (not to_exists) then f_action ~from_absolute ~to_absolute else ();
            in
            result_add_ok_file ~r:acc ~event ~from_absolute ~to_absolute ~from_relative:from_entry ~to_relative
          with
          | exc ->
            result_add_error_file ~r:acc ~from_absolute ~to_absolute ~msg:(Printexc.to_string exc) ~from_relative:from_entry ~to_relative
        ) else (
          result_add_ok_file ~r:acc ~event ~from_absolute ~to_absolute ~from_relative:from_entry ~to_relative
        )
      )
    | false ->
      acc

let update_meta_data result =
  let directory (e : result_directory_ok) =
    let f absolute relative =
      try
        let stat = Unix.LargeFile.stat (Com.Directory.get_name absolute) in
        let absolute = Directory.retrieve_mdatetime Com.Directory.set_mdatetime (absolute, Some stat) |> fst in
        let relative = Directory.retrieve_mdatetime Com.Directory.set_mdatetime (relative, Some stat) |> fst in
        (absolute, relative)
      with
      | _ -> (absolute, relative)
    in
    let (from_dir_absolute, from_dir_relative) = f e.from_dir_absolute e.from_dir_relative in
    let (to_dir_absolute, to_dir_relative) = f e.to_dir_absolute e.to_dir_relative in
    { e with from_dir_absolute; to_dir_absolute; from_dir_relative; to_dir_relative }
  in
  let file (e : result_file_ok) =
    let f absolute relative =
      try
        let directory = Com.Path.get_directory absolute |> Option.get in
        let file = Com.Path.get_file absolute |> Option.get in
        let stat = Unix.LargeFile.stat (Filename.concat (Com.Directory.get_name directory) (Com.File.get_name file)) in
        let size = stat.Unix.LargeFile.st_size in
        let mtime = stat.Unix.LargeFile.st_mtime |> Datetime.of_mtime in
        let file_absolute = Com.Path.get_file absolute |> Option.get |> Com.File.set_size_bytes (Some size) |> Com.File.set_mdatetime (Some mtime) in
        let absolute = Com.Path.set_file file_absolute absolute in
        let file_relative = Com.Path.get_file relative |> Option.get |> Com.File.set_size_bytes (Some size) |> Com.File.set_mdatetime (Some mtime) in
        let relative = Com.Path.set_file file_relative relative in
        (absolute, relative)
      with
      | _ -> (absolute, relative)
    in
    let (from_file_absolute, from_file_relative) = f e.from_file_absolute e.from_file_relative in
    let (to_file_absolute, to_file_relative) = f e.to_file_absolute e.to_file_relative in
    { e with from_file_absolute; to_file_absolute; from_file_relative; to_file_relative }
  in
  let directories_ok = List.map directory result.directories_ok in
  let files_ok = List.map file result.files_ok in
  { result with directories_ok; files_ok }

let action_on_selection ~action ~from_root ~from_subdir ~to_root ~to_subdir ~dirs ~files ~paste_mode =
  let from_root_dir_name = Directory.concat_absolute from_root from_subdir |> Com.Directory.get_name in
  let to_root_dir_name = Directory.concat_absolute to_root to_subdir |> Com.Directory.get_name in
  let result_dirs = List.fold_left
      (fun acc e -> action_on_entry ~action ~acc ~from_root:from_root_dir_name ~to_root:to_root_dir_name ~paste_mode ~from_entry:(Com.Directory.get_name e) ~to_subdir:"")
      result_empty
      dirs
  in
  let result_dirs_and_files = List.fold_left
      (fun acc e -> action_on_entry ~action ~acc ~from_root:from_root_dir_name ~to_root:to_root_dir_name ~paste_mode ~from_entry:(Com.File.get_name e) ~to_subdir:"")
      result_dirs
      files
  in
  let () = match action with
    | Copy -> ()
    | Move ->
      let calc_level dir =
        let s = Com.Directory.get_name dir in
        let regexp = Str.regexp_string Filename.dir_sep in
        let l = Str.split_delim regexp s in
        List.length l
      in
      result_dirs_and_files.directories_ok
      |> List.sort (fun (a:result_directory_ok) (b:result_directory_ok) -> compare (calc_level b.from_dir_absolute) (calc_level a.from_dir_absolute))
      |> List.map (fun (dir:result_directory_ok) -> Com.Directory.get_name dir.from_dir_absolute)
      |> List.iter (fun dir -> Sys.rmdir dir)
  in
  update_meta_data result_dirs_and_files

let get_result_directories_ok v = v.directories_ok
let get_result_directories_error v = v.directories_error
let get_result_files_ok v = v.files_ok
let get_result_files_error v = v.files_error
let get_ok_from_dir_relative (v : result_directory_ok) = v.from_dir_relative
let get_ok_to_dir_relative (v : result_directory_ok) = v.to_dir_relative
let get_error_from_dir_relative (v : result_directory_error) = v.from_dir_relative
let get_error_to_dir_relative (v : result_directory_error) = v.to_dir_relative
let get_error_dir_msg (v : result_directory_error) = v.msg
let get_ok_from_file_relative (v : result_file_ok) = v.from_file_relative
let get_ok_to_file_relative (v : result_file_ok) = v.to_file_relative
let get_error_from_file_relative (v : result_file_error) = v.from_file_relative
let get_error_to_file_relative (v : result_file_error) = v.to_file_relative
let get_error_file_msg (v : result_file_error) = v.msg