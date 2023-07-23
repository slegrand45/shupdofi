module Com = Shupdofi_com

type t

val make : area_id:string -> subdirs:string list -> old_directory:Com.Directory.relative Com.Directory.t -> new_directory:Com.Directory.relative Com.Directory.t -> t
val get_area_id : t -> string
val get_subdirs : t -> string list
val get_old_directory : t -> Com.Directory.relative Com.Directory.t
val get_new_directory : t -> Com.Directory.relative Com.Directory.t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
