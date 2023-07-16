(*
module Com = Shupdofi_com

type t

val make : area_id:string -> subdirs:string list -> directory:Com.Directory.relative Com.Directory.t -> t
*)

module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.New_directory_created

val get_area_id : Srv.t -> string
val get_subdirs : Srv.t -> string list
val get_directory : Srv.t -> Com.Directory.relative Com.Directory.t
val t_of_yojson : Yojson.Safe.t -> Srv.t

(*
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
*)