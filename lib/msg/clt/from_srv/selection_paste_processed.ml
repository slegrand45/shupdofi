module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_paste_processed

let get_selection = Srv.get_selection
let get_target_area = Srv.get_target_area
let get_target_subdirs = Srv.get_target_subdirs
let t_of_yojson = Srv.t_of_yojson
