type t

val make : id:string -> login:string -> name:string -> groups:Group.t list -> t
val to_toml : t -> string
val get_id : t -> string
val get_login : t -> string
val get_name : t -> string
val get_groups : t -> Group.t list