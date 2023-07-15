type t

val make : area_id:string -> subdirs:string list -> old_filename:string -> new_filename:string -> t
val get_area_id : t -> string
val get_subdirs : t -> string list
val get_old_filename : t -> string
val get_new_filename : t -> string
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
