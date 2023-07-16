module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.File_renamed

val get_area_id : Srv.t -> string
val get_subdirs : Srv.t -> string list
val get_old_file : Srv.t -> Com.File.t
val get_new_file : Srv.t -> Com.File.t
val t_of_yojson : Yojson.Safe.t -> Srv.t
