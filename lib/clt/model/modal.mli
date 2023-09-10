type t

val default : t

val is_new_entry : t -> bool
val is_confirm_delete : t -> bool
val is_selection_cut_copy : t -> bool
val set_new_entry : t -> t
val set_confirm_delete : string -> t -> t
val set_selection_cut_copy : string -> t -> t

val get_title : t -> string
val get_input_content : t -> string
val get_txt_bt_ok : t -> string
val bt_ok_is_disabled : t -> bool
val bt_ok_is_enabled : t -> bool
val get_input_switch : t -> bool
val get_txt_switch : t -> string
val get_txt_bt_cancel : t -> string
val get_fun_bt_ok : t -> (Vdom.mouse_event -> Action.t)

val set_title : string -> t -> t
val set_input_content : string -> t -> t
val set_txt_bt_ok : string -> t -> t
val disable_bt_ok : t -> t
val enable_bt_ok : t -> t
val set_input_switch : bool -> t -> t
val toggle_input_switch : t -> t
val set_txt_bt_cancel : string -> t -> t
val set_fun_bt_ok : (Vdom.mouse_event -> Action.t) -> t -> t
