
module Com = Shupdofi_com

type t

val make : area:Com.Area.t -> subdirs:string list
  -> directories_ok:(Com.Directory.relative Com.Directory.t * Com.Directory.relative Com.Directory.t option) list
  -> directories_ko:Com.Directory.relative Com.Directory.t list
  -> paths_ok:(Com.Directory.relative Com.Path.t * Com.Directory.relative Com.Path.t option) list
  -> paths_ko:Com.Directory.relative Com.Path.t list
  -> t

val get_area : t -> Com.Area.t
val get_subdirs : t -> string list
val get_directories_ok : t -> (Com.Directory.relative Com.Directory.t * Com.Directory.relative Com.Directory.t option) list
val get_directories_ko : t -> Com.Directory.relative Com.Directory.t list
val get_paths_ok : t -> (Com.Directory.relative Com.Path.t * Com.Directory.relative Com.Path.t option) list
val get_paths_ko : t -> Com.Directory.relative Com.Path.t list
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
