module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_processed

let get_area = Srv.get_area
let get_subdirs = Srv.get_subdirs
let get_directories_ok = Srv.get_directories_ok
let get_directories_ko = Srv.get_directories_ko
let get_paths_ok = Srv.get_paths_ok
let get_paths_ko = Srv.get_paths_ko
let t_of_yojson = Srv.t_of_yojson
