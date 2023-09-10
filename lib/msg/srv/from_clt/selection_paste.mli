module Clt = Shupdofi_msg_clt_to_srv.Selection_paste
module Selection = Shupdofi_msg_clt_to_srv.Selection

val get_selection : Clt.t -> Selection.t
val get_overwrite : Clt.t -> bool
val get_target_area_id : Clt.t -> string
val get_target_subdirs : Clt.t -> string list
val t_of_yojson : Yojson.Safe.t -> Clt.t