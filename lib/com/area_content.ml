open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area: Area.t;
  subdirs: string list;
  directories: Directory.relative Directory.t list;
  files: File.t list
}
[@@deriving yojson]

let make ~area ~subdirs ~directories ~files = { area; subdirs; directories; files }

let get_area v = v.area
let get_subdirs v = v.subdirs
let get_directories v = v.directories
let get_files v = v.files

let set_area area v = { v with area }
let set_subdirs subdirs v = { v with subdirs }

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

let sort v =
  let files = List.sort compare v.files in
  { v with files }

