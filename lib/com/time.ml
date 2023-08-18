open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  hour: int;
  minute : int;
  second : int;
}
[@@deriving yojson]

let make ~hour ~minute ~second =
  { hour; minute; second }

let get_hour v = v.hour
let get_minute v = v.minute
let get_second v = v.second

let to_iso8601 v =
  Printf.sprintf "%02d:%02d:%02d" v.hour v.minute v.second
