module Clt = Shupdofi_msg_clt_to_srv.Delete_file

val get_area_id : Clt.t -> string
val get_subdirs : Clt.t -> string list
val get_filename : Clt.t -> string
val t_of_yojson : Yojson.Safe.t -> Clt.t
