type t

val default : t

val get_title : t -> string
val get_content : t -> string
val get_txt_bt_ok : t -> string
val get_txt_bt_cancel : t -> string

val set_title : string -> t -> t
val set_content : string -> t -> t
val set_txt_bt_ok : string -> t -> t
val set_txt_bt_cancel : string -> t -> t
