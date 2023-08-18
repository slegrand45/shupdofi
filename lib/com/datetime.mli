type t

val make : date:Date.t -> time:Time.t -> t
val get_date : t -> Date.t
val get_time : t -> Time.t
val to_iso8601 : t -> string

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t