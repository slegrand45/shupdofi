module Com = Shupdofi_com_com

type t = Com.Time.t

let of_mtime v =
  let tm = Unix.gmtime v in
  Com.Time.make ~hour:tm.Unix.tm_hour ~minute:tm.Unix.tm_min ~second:tm.Unix.tm_sec