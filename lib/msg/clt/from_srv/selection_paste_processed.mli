module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_paste_processed

val get_selection : Srv.t -> Shupdofi_msg_srv_to_clt.Selection_processed.t
val get_target_area : Srv.t -> Com.Area.t
val get_target_subdirs : Srv.t -> string list
val t_of_yojson : Yojson.Safe.t -> Srv.t
