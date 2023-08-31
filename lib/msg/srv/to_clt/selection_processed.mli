
module Com = Shupdofi_com

type t

val make : area:Com.Area.t -> subdirs:string list
  -> directories_ok:Com.Directory.relative Com.Directory.t list
  -> directories_ko:Com.Directory.relative Com.Directory.t list
  -> files_ok:Com.File.t list
  -> files_ko:Com.File.t list
  -> t

val get_area : t -> Com.Area.t
val get_subdirs : t -> string list
val get_directories_ok : t -> Com.Directory.relative Com.Directory.t list
val get_directories_ko : t -> Com.Directory.relative Com.Directory.t list
val get_files_ok : t -> Com.File.t list
val get_files_ko : t -> Com.File.t list
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
