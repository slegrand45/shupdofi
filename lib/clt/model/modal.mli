type t

val default : t

val get_title : t -> string
val get_input_content : t -> string
val get_txt_bt_ok : t -> string
val get_txt_bt_cancel : t -> string
val get_fun_bt_ok : t -> (Vdom.mouse_event -> Action.t)

val set_title : string -> t -> t
val set_input_content : string -> t -> t
val set_txt_bt_ok : string -> t -> t
val set_txt_bt_cancel : string -> t -> t
val set_fun_bt_ok : (Vdom.mouse_event -> Action.t) -> t -> t
