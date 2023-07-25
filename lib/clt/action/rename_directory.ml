module Com = Shupdofi_com

type t =
  | Ask of { directory : Com.Directory.relative Com.Directory.t }
  | Start of { area_id : string; area_subdirs : string list; old_dirname : string }
  | Do of { area_id : string; area_subdirs : string list; toast_id : string; old_dirname : string; new_dirname : string }
  | Done of { toast_id : string; old_dirname : string; new_dirname : string; status : int; json : string }
