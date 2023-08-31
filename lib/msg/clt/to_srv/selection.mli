type t

val make : area_id:string -> subdirs:string list -> dirnames:string list -> filenames: string list -> t
val get_area_id : t -> string
val get_subdirs : t -> string list
val get_dirnames: t -> string list
val get_filenames: t -> string list
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
