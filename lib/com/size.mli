type t

val from_int64 : int64 -> t
val from_string : string -> t option
val to_human : t -> string