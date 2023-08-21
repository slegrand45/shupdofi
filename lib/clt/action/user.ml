type t =
  | Do
  | Done of { status : int; json : string }
  | Error of { toast_id : string; msg : string; }