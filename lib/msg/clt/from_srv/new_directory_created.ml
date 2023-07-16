module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.New_directory_created

let get_area_id = Srv.get_area_id
let get_subdirs = Srv.get_subdirs
let get_directory = Srv.get_directory
let t_of_yojson = Srv.t_of_yojson
