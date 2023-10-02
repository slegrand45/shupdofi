module Com = Shupdofi_com

type result_directory_ok
type result_directory_error
type result_file_ok
type result_file_error
type t

val make : from_area:Com.Area.t -> from_subdirs:string list -> to_area:Com.Area.t -> to_subdirs:string list
  -> directories_ok:result_directory_ok list -> directories_ko:result_directory_error list
  -> paths_ok:result_file_ok list -> paths_ko:result_file_error list -> t

val make_directory_ok : from_dir:Com.Directory.relative Com.Directory.t -> to_dir:Com.Directory.relative Com.Directory.t -> result_directory_ok
val make_directory_error : from_dir:Com.Directory.relative Com.Directory.t -> to_dir:Com.Directory.relative Com.Directory.t -> msg:string -> result_directory_error
val make_file_ok : from_file:Com.Directory.relative Com.Path.t -> to_file:Com.Directory.relative Com.Path.t -> result_file_ok
val make_file_error : from_file:Com.Directory.relative Com.Path.t -> to_file:Com.Directory.relative Com.Path.t -> msg:string -> result_file_error

val get_from_area : t -> Com.Area.t
val get_from_subdirs : t -> string list
val get_to_area : t -> Com.Area.t
val get_to_subdirs : t -> string list
val get_directories_ok : t -> result_directory_ok list
val get_directories_ko : t -> result_directory_error list
val get_paths_ok : t -> result_file_ok list
val get_paths_ko : t -> result_file_error list
val get_directory_ok_from_dir : result_directory_ok -> Com.Directory.relative Com.Directory.t
val get_directory_ok_to_dir : result_directory_ok -> Com.Directory.relative Com.Directory.t
val get_directory_error_from_dir : result_directory_error -> Com.Directory.relative Com.Directory.t
val get_directory_error_to_dir : result_directory_error -> Com.Directory.relative Com.Directory.t
val get_directory_error_msg : result_directory_error -> string
val get_file_ok_from_file : result_file_ok -> Com.Directory.relative Com.Path.t
val get_file_ok_to_file : result_file_ok -> Com.Directory.relative Com.Path.t
val get_file_error_from_file : result_file_error -> Com.Directory.relative Com.Path.t
val get_file_error_to_file : result_file_error -> Com.Directory.relative Com.Path.t
val get_file_error_msg : result_file_error -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t

(*
module Com = Shupdofi_com

type t

val make : selection:Selection_processed.t -> target_area:Com.Area.t -> target_subdirs:string list -> t

val get_selection : t -> Selection_processed.t
val get_target_area : t -> Com.Area.t
val get_target_subdirs : t -> string list
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
*)