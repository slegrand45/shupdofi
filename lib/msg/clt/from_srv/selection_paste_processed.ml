module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Selection_paste_processed

let get_from_area = Srv.get_from_area
let get_from_subdirs = Srv.get_from_subdirs
let get_to_area = Srv.get_to_area
let get_to_subdirs = Srv.get_to_subdirs
let get_directories_ok = Srv.get_directories_ok
let get_directories_ko = Srv.get_directories_ko
let get_paths_ok = Srv.get_paths_ok
let get_paths_ko = Srv.get_paths_ko
let get_directory_ok_from_dir = Srv.get_directory_ok_from_dir
let get_directory_ok_to_dir = Srv.get_directory_ok_to_dir
let get_directory_error_from_dir = Srv.get_directory_error_from_dir
let get_directory_error_to_dir = Srv.get_directory_error_to_dir
let get_directory_error_msg = Srv.get_directory_error_msg
let get_file_ok_from_file = Srv.get_file_ok_from_file
let get_file_ok_to_file = Srv.get_file_ok_to_file
let get_file_error_from_file = Srv.get_file_error_from_file
let get_file_error_to_file = Srv.get_file_error_to_file
let get_file_error_msg = Srv.get_file_error_msg

let t_of_yojson = Srv.t_of_yojson