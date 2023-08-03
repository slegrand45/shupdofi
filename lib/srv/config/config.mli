module Com = Shupdofi_com

type t

val to_toml : t -> string
val get_server : t -> Server.t
val get_areas : t -> Com.Area.collection
val get_groups : t -> Group.t list
val get_users : t -> User.t list

(* force absolute path ? *)
val from_toml_file : string -> (t, string) result