module Com = Shupdofi_com

type t =
  | Nothing
  | Area_go_to_subdir of { name : string }
  | Current_url_modified
  | Fetch of { block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t }
  | Fetch_start of { block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t }
  | Fetched of { block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t; json : string }
  | Set_current_url of { url : string }
  | Upload_file_start of { input_file_id : string }
  | Upload_file of { area_id : string; area_subdirs : string list; toast_id : string; file : Js_browser.File.t }
  | Uploaded_file of { toast_id : string; status : int; json : string; filename : string }
  | New_directory_ask_dirname
  | New_directory_start of { area_id : string; area_subdirs : string list }
  | New_directory of { area_id : string; area_subdirs : string list; toast_id : string; dirname : string }
  | New_directory_done of { toast_id : string; status : int; json : string; dirname : string }

  | Rename_directory_ask_dirname of { directory : Com.Directory.relative Com.Directory.t }
  | Rename_directory_start of { area_id : string; area_subdirs : string list; old_dirname : string }
  | Rename_directory of { area_id : string; area_subdirs : string list; toast_id : string; old_dirname : string; new_dirname : string }
  | Rename_directory_done of { toast_id : string; old_dirname : string; new_dirname : string; status : int; json : string }

  | Delete_directory_ask_confirm of { directory : Com.Directory.relative Com.Directory.t }

  | Delete_file_ask_confirm of { file : Com.File.t }
  | Delete_file_start of { area_id : string; area_subdirs : string list; filename : string }
  | Delete_file of { area_id : string; area_subdirs : string list; toast_id : string; filename : string }
  | Delete_file_done of { area_id : string ; area_subdirs : string list; toast_id : string; filename : string; status : int }
  | Rename_file_ask_filename of { file : Com.File.t }
  | Rename_file_start of { area_id : string; area_subdirs : string list; old_filename : string }
  | Rename_file of { area_id : string; area_subdirs : string list; toast_id : string; old_filename : string; new_filename : string }
  | Rename_file_done of { toast_id : string; old_filename : string; new_filename : string; status : int; json : string }
  | Modal_set_input_content of { content : string }
  | Modal_toggle_switch
  | Modal_close
  | Modal_cancel
