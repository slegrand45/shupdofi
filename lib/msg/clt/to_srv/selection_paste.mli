module Com = Shupdofi_com

type t

val make : selection:Selection.t -> action:Com.Path.copy_move -> paste_mode:Com.Path.paste -> target_area_id:string -> target_subdirs:string list -> t
val get_selection : t -> Selection.t
val get_action : t -> Com.Path.copy_move
val get_paste_mode : t -> Com.Path.paste
val get_target_area_id : t -> string
val get_target_subdirs : t -> string list
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
