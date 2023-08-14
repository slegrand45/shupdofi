type t

val make : name:string -> areas_rights:(string * Action.t list) list -> t
val empty : t
val get_name : t -> string
val get_areas_rights : t -> (string * Action.t list) list
val can_do_action : area_id:string -> action:Action.t -> t -> bool
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
