type t =
  | Clear
  | Delete_ask
  | Delete_start of { area_id : string; subdirs : string list; dirnames : string list; filenames : string list }
  | Delete_do of { toast_id : string; area_id : string; subdirs : string list; dirnames : string list; filenames : string list }
  | Delete_done of { toast_id : string; area_id : string; subdirs : string list; status : int; json : string }