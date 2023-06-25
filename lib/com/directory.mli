type t

val make : name:string -> ?mdatetime:Datetime.t -> unit -> t
val is_defined : t -> bool
val get_name : t -> string
val get_mdatetime : t -> Datetime.t option
val set_name : string -> t -> t
val set_mdatetime : Datetime.t option -> t -> t

val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
