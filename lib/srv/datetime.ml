module Com = Shupdofi_com

type t = Com.Datetime.t

let of_mtime v =
  let date = Date.of_mtime v in
  let time = Time.of_mtime v in
  Com.Datetime.make ~date ~time