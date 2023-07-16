open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  filename: string;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~filename = { area_id; subdirs; filename }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_filename v = v.filename
