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
  | New_directory_created of { toast_id : string; status : int; json : string; dirname : string }
  | Modal_set_input_content of { content : string }
  | Modal_close
  | Modal_cancel
