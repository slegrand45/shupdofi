module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_processed

val get_area : Srv.t -> Com.Area.t
val get_subdirs : Srv.t -> string list
val get_directories_ok : Srv.t -> Com.Directory.relative Com.Directory.t list
val get_directories_ko : Srv.t -> Com.Directory.relative Com.Directory.t list
val get_files_ok : Srv.t -> Com.File.t list
val get_files_ko : Srv.t -> Com.File.t list
val t_of_yojson : Yojson.Safe.t -> Srv.t
