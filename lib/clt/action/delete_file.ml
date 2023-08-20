module Com = Shupdofi_com

type t =
  | Ask of { file : Com.File.t }
  | Start of { area_id : string; subdirs : string list; filename : string }
  | Do of { area_id : string; subdirs : string list; toast_id : string; filename : string }
  | Done of { area_id : string ; subdirs : string list; toast_id : string; filename : string; status : int }