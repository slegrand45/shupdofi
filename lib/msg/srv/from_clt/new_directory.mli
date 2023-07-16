(*
type t

val make : area_id:string -> subdirs:string list -> dirname:string -> t
*)

module Clt = Shupdofi_msg_clt_to_srv.New_directory

val get_area_id : Clt.t -> string
val get_subdirs : Clt.t -> string list
val get_dirname : Clt.t -> string
val t_of_yojson : Yojson.Safe.t -> Clt.t

(*
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
*)