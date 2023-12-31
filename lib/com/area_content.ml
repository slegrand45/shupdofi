open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area: Area.t;
  subdirs: string list;
  directories: Directory.relative Directory.t list;
  files: File.t list
}
[@@deriving yojson]

let make ~area ~subdirs ~directories ~files = { area; subdirs; directories; files }

let to_string v =
  let area_id = Area.get_id v.area in
  let subdirs = String.concat "/" v.subdirs in
  let directories = String.concat ", " (List.map Directory.get_name v.directories) in
  let files = String.concat ", " (List.map File.get_name v.files) in
  Printf.sprintf "%s: %s: directories=%s files=%s" area_id subdirs directories files

let get_area v = v.area
let get_subdirs v = v.subdirs
let get_directories v = v.directories
let get_files v = v.files

let set_area area v = { v with area }
let set_subdirs subdirs v = { v with subdirs }
let set_directories directories v = { v with directories }
let set_files files v = { v with files }

let add_uploaded ~id ~subdirs ~file v =
  let l = List.filter (fun e -> File.get_name e <> File.get_name file) v.files in
  if id = Area.get_id v.area && subdirs = v.subdirs then
    { v with files = file :: l }
  else
    v

let add_new_path ~id ~subdirs ~path v =
  if id = Area.get_id v.area && subdirs = v.subdirs then (
    let directory_name = Option.get (Path.get_directory path) |> Directory.get_name in
    let subdir = String.concat (Filename.dir_sep) v.subdirs in
    if ((Filename.dirname directory_name = Filename.current_dir_name && Filename.basename directory_name = Filename.current_dir_name)
        || directory_name = subdir) then (
      let file = Option.get (Path.get_file path) in
      let l = List.filter (fun e -> File.get_name e <> File.get_name file) v.files in
      { v with files = file :: l }
    ) else
      v
  ) else
    v

let add_new_directory ~id ~subdirs ~directory v =
  if id = Area.get_id v.area && subdirs = v.subdirs then (
    let directory_name = Directory.get_name directory in
    let subdir = String.concat (Filename.dir_sep) subdirs in
    if (Filename.dirname directory_name = Filename.current_dir_name || Filename.dirname directory_name = subdir) then (
      let l = List.filter (fun e -> Directory.get_name e <> directory_name) v.directories in
      { v with directories = directory :: l }
    ) else
      v
  ) else
    v

let rename_directory ~id ~subdirs ~old_directory ~new_directory v =
  if id = Area.get_id v.area && subdirs = v.subdirs then
    let l = List.filter (fun e -> Directory.get_name e <> Directory.get_name old_directory) v.directories in
    { v with directories = new_directory :: l }
  else
    v

let rename_file ~id ~subdirs ~old_file ~new_file v =
  if id = Area.get_id v.area && subdirs = v.subdirs then
    let l = List.filter (fun e -> File.get_name e <> File.get_name old_file) v.files in
    { v with files = new_file :: l }
  else
    v

let remove_file ~id ~subdirs ~filename v =
  if id = Area.get_id v.area && subdirs = v.subdirs then
    { v with files = List.filter (fun e -> File.get_name e <> filename) v.files }
  else
    v

let remove_directory ~id ~subdirs ~dirname v =
  if id = Area.get_id v.area && subdirs = v.subdirs then
    { v with directories = List.filter (fun e -> Directory.get_name e <> dirname) v.directories }
  else
    v

let sort sorting v =
  let criteria = Sorting.get_criteria sorting in
  let direction = Sorting.get_direction sorting in
  let f_sort_directory_last_modified e =
    Directory.get_mdatetime e |> Option.fold ~none:"" ~some:Datetime.to_iso8601
  in
  let f_sort_file_last_modified e =
    File.get_mdatetime e |> Option.fold ~none:"" ~some:Datetime.to_iso8601
  in
  let f_sort_file_size e =
    File.get_size_bytes e |> Option.fold ~none:"" ~some:(fun e -> Printf.sprintf "%32Lu" e)
  in
  let f_compare_directory e1 e2 =
    match criteria with
    | Sorting.Criteria.Name
    | Sorting.Criteria.Size -> (
        match String.compare (Directory.get_name e1) (Directory.get_name e2) with
        | 0 -> String.compare (f_sort_directory_last_modified e1) (f_sort_directory_last_modified e2)
        | v -> v
      )
    | Sorting.Criteria.Last_modified -> (
        match String.compare (f_sort_directory_last_modified e1) (f_sort_directory_last_modified e2) with
        | 0 -> String.compare (Directory.get_name e1) (Directory.get_name e2)
        | v -> v
      )
  in
  let f_compare_file e1 e2 =
    match criteria with
    | Sorting.Criteria.Name -> (
        match String.compare (File.get_name e1) (File.get_name e2) with
        | 0 -> (
            match String.compare (f_sort_file_last_modified e1) (f_sort_file_last_modified e2) with
            | 0 -> String.compare (f_sort_file_size e1) (f_sort_file_size e2)
            | v -> v
          )
        | v -> v
      )
    | Sorting.Criteria.Last_modified -> (
        match String.compare (f_sort_file_last_modified e1) (f_sort_file_last_modified e2) with
        | 0 -> (
            match String.compare (File.get_name e1) (File.get_name e2) with
            | 0 -> String.compare (f_sort_file_size e1) (f_sort_file_size e2)
            | v -> v
          )
        | v -> v
      )
    | Sorting.Criteria.Size -> (
        match String.compare (f_sort_file_size e1) (f_sort_file_size e2) with
        | 0 -> (
            match String.compare (File.get_name e1) (File.get_name e2) with
            | 0 -> String.compare (f_sort_file_last_modified e1) (f_sort_file_last_modified e2)
            | v -> v
          )
        | v -> v
      )
  in
  let mult =
    match direction with
    | Sorting.Direction.Ascending -> 1
    | Sorting.Direction.Descending -> -1
  in
  let directories = List.sort (fun e1 e2 -> mult * (f_compare_directory e1 e2)) v.directories in
  let files = List.sort (fun e1 e2 -> mult * (f_compare_file e1 e2)) v.files in
  { v with directories; files }
