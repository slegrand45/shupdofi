open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  file: File.t
}
[@@deriving yojson]

let make ~area_id ~subdirs ~file = { area_id; subdirs; file }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_file v = v.file
