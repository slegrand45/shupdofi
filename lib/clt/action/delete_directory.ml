module Com = Shupdofi_com

type t =
  | Ask of { directory : Com.Directory.relative Com.Directory.t }
  | Start of { area_id : string; area_subdirs : string list; dirname : string }
  | Do of { area_id : string; area_subdirs : string list; toast_id : string; dirname : string }
  | Done of { area_id : string ; area_subdirs : string list; toast_id : string; dirname : string; status : int }
