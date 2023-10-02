module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_paste_processed

val get_from_area : Srv.t -> Com.Area.t
val get_from_subdirs : Srv.t -> string list
val get_to_area : Srv.t -> Com.Area.t
val get_to_subdirs : Srv.t -> string list
val get_directories_ok : Srv.t -> Srv.result_directory_ok list
val get_directories_ko : Srv.t -> Srv.result_directory_error list
val get_paths_ok : Srv.t -> Srv.result_file_ok list
val get_paths_ko : Srv.t -> Srv.result_file_error list
val get_directory_ok_from_dir : Srv.result_directory_ok -> Com.Directory.relative Com.Directory.t
val get_directory_ok_to_dir : Srv.result_directory_ok -> Com.Directory.relative Com.Directory.t
val get_directory_error_from_dir : Srv.result_directory_error -> Com.Directory.relative Com.Directory.t
val get_directory_error_to_dir : Srv.result_directory_error -> Com.Directory.relative Com.Directory.t
val get_directory_error_msg : Srv.result_directory_error -> string
val get_file_ok_from_file : Srv.result_file_ok -> Com.Directory.relative Com.Path.t
val get_file_ok_to_file : Srv.result_file_ok -> Com.Directory.relative Com.Path.t
val get_file_error_from_file : Srv.result_file_error -> Com.Directory.relative Com.Path.t
val get_file_error_to_file : Srv.result_file_error -> Com.Directory.relative Com.Path.t
val get_file_error_msg : Srv.result_file_error -> string

val t_of_yojson : Yojson.Safe.t -> Srv.t