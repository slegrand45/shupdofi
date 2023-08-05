type t

val make : authentications:Authentication.Id.t list -> t
val to_toml : t -> string
val get_authentications : t -> Authentication.Id.t list