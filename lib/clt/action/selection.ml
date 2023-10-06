module Com = Shupdofi_com

type t =
  | Clear
  | Delete_ask
  | Delete_start of { area_id : string; subdirs : string list; dirnames : string list; filenames : string list }
  | Delete_do of { toast_id : string; area_id : string; subdirs : string list; dirnames : string list; filenames : string list }
  | Delete_done of { toast_id : string; area_id : string; subdirs : string list; status : int; json : string }
  | Download_start
  | Download_do of { toast_id : string; area_id : string; subdirs : string list; dirnames : string list; filenames : string list }
  | Download_done of { toast_id : string; status : int; data : Ojs.t }
  | Copy_move_ask of Com.Path.copy_move
  | Copy_move_start of { action : Com.Path.copy_move; area_id : string; subdirs : string list; dirnames : string list; filenames : string list; target_area_id : string; target_subdirs : string list }
  | Copy_move_do of { action : Com.Path.copy_move; toast_id : string; area_id : string; subdirs : string list; dirnames : string list; filenames : string list; target_area_id : string; target_subdirs : string list; paste_mode : Com.Path.paste }
  | Copy_move_done of { action : Com.Path.copy_move; toast_id : string; target_area_id : string; target_subdirs : string list; status : int; json : string }
