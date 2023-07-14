type absolute
type relative
type 'a t

val make_absolute : name:string -> ?mdatetime:Datetime.t -> unit -> absolute t
val make_relative : name:string -> ?mdatetime:Datetime.t -> unit -> relative t
val is_defined : 'a t -> bool
val get_name : 'a t -> string
val get_mdatetime : 'a t -> Datetime.t option
val set_name : string -> 'a t -> 'a t
val set_mdatetime : Datetime.t option -> 'a t -> 'a t

val absolute_of_yojson : Yojson.Safe.t -> absolute
val yojson_of_absolute : absolute -> Yojson.Safe.t
val relative_of_yojson : Yojson.Safe.t -> relative
val yojson_of_relative : relative -> Yojson.Safe.t
val t_of_yojson : (Yojson.Safe.t -> 'a) -> Yojson.Safe.t -> 'a t
val yojson_of_t : ('a -> Yojson.Safe.t) -> 'a t -> Yojson.Safe.t