module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_processed

val get_area : Srv.t -> Com.Area.t
val get_subdirs : Srv.t -> string list
val get_directories_ok : Srv.t -> Com.Directory.relative Com.Directory.t list
val get_directories_ko : Srv.t -> Com.Directory.relative Com.Directory.t list
val get_paths_ok : Srv.t -> Com.Directory.relative Com.Path.t list
val get_paths_ko : Srv.t -> Com.Directory.relative Com.Path.t list
val t_of_yojson : Yojson.Safe.t -> Srv.t
