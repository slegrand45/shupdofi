module Clt = Shupdofi_clt

open Clt.Block

type t =
  | Area_go_to_subdir of string
  | Current_url_modified
  | Fetch of (Fetchable.id, Fetchable.status) Fetchable.t
  | Fetch_start of (Fetchable.id, Fetchable.status) Fetchable.t
  | Fetched of ((Fetchable.id, Fetchable.status) Fetchable.t * string)
  | Set_current_url of string
  (* | Upload_file of string *)

  | Upload_file_start of string
  | Upload_file of (string * string list * string * Js_browser.File.t)
  | Uploaded_file of (string * int * string)