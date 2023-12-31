module Clt = Shupdofi_msg_clt_to_srv.Selection_paste
module Com = Shupdofi_com
module Selection = Shupdofi_msg_clt_to_srv.Selection

let get_selection = Clt.get_selection
let get_action = Clt.get_action
let get_paste_mode = Clt.get_paste_mode
let get_target_area_id = Clt.get_target_area_id
let get_target_subdirs = Clt.get_target_subdirs
let t_of_yojson = Clt.t_of_yojson
