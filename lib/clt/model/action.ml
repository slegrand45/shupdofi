type t =
  | Nothing
  | Area_go_to_subdir of string
  | Current_url_modified
  | Fetch of (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t
  | Fetch_start of (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t
  | Fetched of ((Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t * string)
  | Set_current_url of string
  (* | Upload_file of string *)

  | Upload_file_start of string
  | Upload_file of (string * string list * string * Js_browser.File.t)
  | Uploaded_file of (string * int * string)

  | New_directory_start
  | New_directory of (string * string list)

  | Modal_set_input_content of string
  | Modal_close
  | Modal_cancel
  (* | Modal_ok *)
