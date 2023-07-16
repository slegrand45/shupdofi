module Com = Shupdofi_com_com

type t = Com.Date.t

let of_mtime v =
  let tm = Unix.gmtime v in
  Com.Date.make ~day_of_month:tm.Unix.tm_mday ~month:(tm.Unix.tm_mon + 1) ~year:(tm.Unix.tm_year + 1900)