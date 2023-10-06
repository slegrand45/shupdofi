module Com = Shupdofi_com

open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  selection: Selection.t;
  action: Com.Path.copy_move;
  paste_mode: Com.Path.paste;
  target_area_id: string;
  target_subdirs: string list;
}
[@@deriving yojson]

let make ~selection ~action ~paste_mode ~target_area_id ~target_subdirs = { selection; action; paste_mode; target_area_id; target_subdirs }

let get_selection v = v.selection
let get_action v = v.action
let get_paste_mode v = v.paste_mode
let get_target_area_id v = v.target_area_id
let get_target_subdirs v = v.target_subdirs
