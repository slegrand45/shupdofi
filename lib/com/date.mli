type t

val make : day_of_month:int -> month:int -> year:int -> t
val get_day_of_month : t -> int
val get_month : t -> int
val get_year : t -> int
val to_string : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t