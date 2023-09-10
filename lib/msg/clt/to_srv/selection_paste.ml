open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  selection: Selection.t;
  overwrite: bool;
  target_area_id: string;
  target_subdirs: string list;
}
[@@deriving yojson]

let make ~selection ~overwrite ~target_area_id ~target_subdirs = { selection; overwrite; target_area_id; target_subdirs }

let get_selection v = v.selection
let get_overwrite v = v.overwrite
let get_target_area_id v = v.target_area_id
let get_target_subdirs v = v.target_subdirs
