type t

val make : hour:int -> minute:int -> second:int -> t
val get_hour : t -> int
val get_minute : t -> int
val get_second : t -> int
val to_string : t -> string
val to_hm : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t