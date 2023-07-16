open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com_com

type t = {
  id: string;
  subdirs: string list;
  directories: Com.Directory.relative Com.Directory.t list;
  files: Com.File.t list
}
[@@deriving yojson]

let make ~id ~subdirs ~directories ~files = { id; subdirs; directories; files }

let get_id v = v.id
let get_subdirs v = v.subdirs
let get_directories v = v.directories
let get_files v = v.files

let set_id id v = { v with id }
let set_subdirs subdirs v = { v with subdirs }

let add_uploaded uploaded v =
  let area_id = Uploaded.get_area_id uploaded in
  let subdirs = Uploaded.get_subdirs uploaded in
  let file = Uploaded.get_file uploaded in
  if area_id = v.id && subdirs = v.subdirs then
    { v with files = file :: v.files }
  else
    v

let add_new_directory new_directory v =
  let area_id = New_directory_created.get_area_id new_directory in
  let subdirs = New_directory_created.get_subdirs new_directory in
  let directory = New_directory_created.get_directory new_directory in
  if area_id = v.id && subdirs = v.subdirs then
    { v with directories = directory :: v.directories }
  else
    v

let rename_file file_renamed v =
  let area_id = File_renamed.get_area_id file_renamed in
  let subdirs = File_renamed.get_subdirs file_renamed in
  let old_file = File_renamed.get_old_file file_renamed in
  let new_file = File_renamed.get_new_file file_renamed in
  if area_id = v.id && subdirs = v.subdirs then
    let l = List.filter (fun e -> Com.File.get_name e <> Com.File.get_name old_file) v.files in
    { v with files = new_file :: l }
  else
    v

let remove_file ~id ~subdirs ~filename v =
  if id = v.id && subdirs = v.subdirs then
    { v with files = List.filter (fun e -> Com.File.get_name e <> filename) v.files }
  else
    v

let sort v =
  let files = List.sort compare v.files in
  { v with files }

