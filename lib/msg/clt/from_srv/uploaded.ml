module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Uploaded

let get_area_id = Srv.get_area_id
let get_subdirs = Srv.get_subdirs
let get_file = Srv.get_file
let t_of_yojson = Srv.t_of_yojson
