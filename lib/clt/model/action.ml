module Com = Shupdofi_com
module Action_other = Shupdofi_clt_action

type t =
  | Nothing
  | Area_go_to_subdir of { name : string }
  | Current_url_modified
  | Fetch of { block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t }
  | Fetch_start of { block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t }
  | Fetched of { block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t; status : int; json : string }
  | Set_current_url of { url : string }
  | Upload_file of Action_other.Upload_file.t
  | New_directory of Action_other.New_directory.t
  | Rename_directory of Action_other.Rename_directory.t
  | Delete_directory of Action_other.Delete_directory.t
  | Rename_file of Action_other.Rename_file.t
  | Delete_file of Action_other.Delete_file.t
  | Modal_set_input_content of { content : string }
  | Modal_toggle_switch
  | Modal_close
  | Modal_cancel
