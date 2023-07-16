module Com = Shupdofi_com_com

type t

val make : area_id:string -> subdirs:string list -> old_file:Com.File.t -> new_file:Com.File.t -> t
val get_area_id : t -> string
val get_subdirs : t -> string list
val get_old_file : t -> Com.File.t
val get_new_file : t -> Com.File.t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
