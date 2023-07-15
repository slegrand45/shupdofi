open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  old_filename: string;
  new_filename: string;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~old_filename ~new_filename = { area_id; subdirs; old_filename; new_filename }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_old_filename v = v.old_filename
let get_new_filename v = v.new_filename
