type t

val make : id:string -> name:string -> description:string -> t
val to_toml : t -> string
val to_string : t -> string
val get_id : t -> string
val get_name : t -> string
val get_description : t -> string