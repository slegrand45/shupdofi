module Com = Shupdofi_com

type t

val to_toml : t -> string
val get_server : t -> Server.t
val get_application : t -> Application.t
val get_authentications : t -> Authentication.t list
val get_areas : t -> Area.t list
val get_groups : t -> Group.t list
val get_users : t -> User.t list
val get_areas_accesses : t -> Area_access.t list
val find_area_with_id : string -> t -> Area.t

(* force absolute path ? *)
val from_toml_file : string -> (t, string) result