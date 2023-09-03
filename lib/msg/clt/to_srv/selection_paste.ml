open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  selection: Selection.t;
  target_area_id: string;
  target_subdirs: string list;
}
[@@deriving yojson]

let make ~selection ~target_area_id ~target_subdirs = { selection; target_area_id; target_subdirs }

let get_selection v = v.selection
let get_target_area_id v = v.target_area_id
let get_target_subdirs v = v.target_subdirs
