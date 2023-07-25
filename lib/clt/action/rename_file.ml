module Com = Shupdofi_com

type t =
  | Ask of { file : Com.File.t }
  | Start of { area_id : string; area_subdirs : string list; old_filename : string }
  | Do of { area_id : string; area_subdirs : string list; toast_id : string; old_filename : string; new_filename : string }
  | Done of { toast_id : string; old_filename : string; new_filename : string; status : int; json : string }