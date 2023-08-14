type t =
  | Do
  | Done of { status : int; json : string }