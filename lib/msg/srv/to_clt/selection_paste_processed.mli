
module Com = Shupdofi_com

type t

val make : selection:Selection_processed.t -> target_area:Com.Area.t -> target_subdirs:string list -> t

val get_selection : t -> Selection_processed.t
val get_target_area : t -> Com.Area.t
val get_target_subdirs : t -> string list
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
