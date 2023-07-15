type t

val make : area_id:string -> subdirs:string list -> old_file:File.t -> new_file:File.t -> t
val get_area_id : t -> string
val get_subdirs : t -> string list
val get_old_file : t -> File.t
val get_new_file : t -> File.t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
