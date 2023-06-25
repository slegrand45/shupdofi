type t

val make : Directory.t -> File.t -> t
val is_defined : t -> bool
val get_directory : t -> Directory.t option
val get_file : t -> File.t option
val set_directory : Directory.t -> t -> t
val set_file : File.t -> t -> t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
