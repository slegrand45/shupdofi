open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  selection: Selection_processed.t;
  target_area: Com.Area.t;
  target_subdirs: string list;
}
[@@deriving yojson]

let make ~selection ~target_area ~target_subdirs =
  { selection; target_area; target_subdirs }

let get_selection v = v.selection
let get_target_area v = v.target_area
let get_target_subdirs v = v.target_subdirs
