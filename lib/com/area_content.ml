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

let add_new_directory ~id ~subdirs ~directory v =
  if id = Area.get_id v.area && subdirs = v.subdirs then
    { v with directories = directory :: v.directories }
  else
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
  let f_field_directory, f_field_file =
    match criteria with
    | Sorting.Criteria.Name ->
      Directory.get_name, File.get_name
    | Sorting.Criteria.Last_modified ->
      (fun e -> Directory.get_mdatetime e |> Option.fold ~none:"" ~some:Datetime.to_iso8601),
      (fun e -> File.get_mdatetime e |> Option.fold ~none:"" ~some:Datetime.to_iso8601)
    | Sorting.Criteria.Size ->
      Directory.get_name, (fun e -> File.get_size_bytes e |> Option.fold ~none:"" ~some:(fun e -> Printf.sprintf "%32Lu" e))
  in
  let mult =
    match direction with
    | Sorting.Direction.Ascending -> 1
    | Sorting.Direction.Descending -> -1
  in
  let directories = List.sort (fun e1 e2 -> mult * (String.compare (f_field_directory e1) (f_field_directory e2))) v.directories in
  let files = List.sort (fun e1 e2 -> mult * (String.compare (f_field_file e1) (f_field_file e2))) v.files in
  { v with directories; files }
