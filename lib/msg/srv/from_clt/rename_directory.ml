module Clt = Shupdofi_msg_clt_to_srv.Rename_directory

let get_area_id = Clt.get_area_id
let get_subdirs = Clt.get_subdirs
let get_old_dirname = Clt.get_old_dirname
let get_new_dirname = Clt.get_new_dirname
let t_of_yojson = Clt.t_of_yojson