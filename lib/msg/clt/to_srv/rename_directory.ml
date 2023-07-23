open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  old_dirname: string;
  new_dirname: string;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~old_dirname ~new_dirname = { area_id; subdirs; old_dirname; new_dirname }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_old_dirname v = v.old_dirname
let get_new_dirname v = v.new_dirname
