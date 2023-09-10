type t

val all : t
val download : t
val upload : t
val rename : t
val delete : t
val create_directory : t
val from_string : string -> t
val to_string : t -> string
val to_toml : t -> string
val is_unknown : t -> bool
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t