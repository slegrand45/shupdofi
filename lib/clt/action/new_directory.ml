type t =
  | Ask
  | Start of { area_id : string; subdirs : string list }
  | Do of { area_id : string; subdirs : string list; toast_id : string; dirname : string }
  | Done of { toast_id : string; status : int; json : string; dirname : string }