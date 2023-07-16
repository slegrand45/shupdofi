(*
module Com = Shupdofi_com

type t

val make : area_id:string -> subdirs:string list -> file:Com.File.t -> t
*)

module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Uploaded

val get_area_id : Srv.t -> string
val get_subdirs : Srv.t -> string list
val get_file : Srv.t -> Com.File.t
val t_of_yojson : Yojson.Safe.t -> Srv.t

(*
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
*)