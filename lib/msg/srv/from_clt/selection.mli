module Clt = Shupdofi_msg_clt_to_srv.Selection

val get_area_id : Clt.t -> string
val get_subdirs : Clt.t -> string list
val get_dirnames: Clt.t -> string list
val get_filenames: Clt.t -> string list
val t_of_yojson : Yojson.Safe.t -> Clt.t