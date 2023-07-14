type t
type collection = t list

val make : id:string -> name:string -> description:string -> root:Directory.absolute Directory.t -> t
val get_id : t -> string
val get_name : t -> string
val get_description : t -> string
val get_root : t -> Directory.absolute Directory.t
val find_with_id : string -> collection -> t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
val collection_of_yojson : Yojson.Safe.t -> collection
val yojson_of_collection : collection -> Yojson.Safe.t