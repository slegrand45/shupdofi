open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  (* or Directory.t list ?? *)
  subdirs: string list;
  directory: Directory.t;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~directory = { area_id; subdirs; directory }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_directory v = v.directory
