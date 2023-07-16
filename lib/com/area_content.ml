open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  id: string;
  subdirs: string list;
  directories: Directory.relative Directory.t list;
  files: File.t list
}
[@@deriving yojson]

let make ~id ~subdirs ~directories ~files = { id; subdirs; directories; files }

let get_id v = v.id
let get_subdirs v = v.subdirs
let get_directories v = v.directories
let get_files v = v.files

let set_id id v = { v with id }
let set_subdirs subdirs v = { v with subdirs }

let add_uploaded ~id ~subdirs ~file v =
  if id = v.id && subdirs = v.subdirs then
    { v with files = file :: v.files }
  else
    v

let add_new_directory ~id ~subdirs ~directory v =
  if id = v.id && subdirs = v.subdirs then
    { v with directories = directory :: v.directories }
  else
    v

let rename_file ~id ~subdirs ~old_file ~new_file v =
  if id = v.id && subdirs = v.subdirs then
    let l = List.filter (fun e -> File.get_name e <> File.get_name old_file) v.files in
    { v with files = new_file :: l }
  else
    v

let remove_file ~id ~subdirs ~filename v =
  if id = v.id && subdirs = v.subdirs then
    { v with files = List.filter (fun e -> File.get_name e <> filename) v.files }
  else
    v

let sort v =
  let files = List.sort compare v.files in
  { v with files }

