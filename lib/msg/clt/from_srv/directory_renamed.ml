module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Directory_renamed

let get_area_id = Srv.get_area_id
let get_subdirs = Srv.get_subdirs
let get_old_directory = Srv.get_old_directory
let get_new_directory = Srv.get_new_directory
let t_of_yojson = Srv.t_of_yojson
