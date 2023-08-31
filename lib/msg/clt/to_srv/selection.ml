open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  dirnames: string list;
  filenames: string list;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~dirnames ~filenames = { area_id; subdirs; dirnames; filenames }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_dirnames v = v.dirnames
let get_filenames v = v.filenames
