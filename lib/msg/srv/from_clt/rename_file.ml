module Clt = Shupdofi_msg_clt_to_srv.Rename_file

let get_area_id = Clt.get_area_id
let get_subdirs = Clt.get_subdirs
let get_old_filename = Clt.get_old_filename
let get_new_filename = Clt.get_new_filename
let t_of_yojson = Clt.t_of_yojson