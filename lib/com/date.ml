open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  day_of_month: int;
  month : int;
  year : int;
}
[@@deriving yojson]

let make ~day_of_month ~month ~year =
  { day_of_month; month; year }

let get_day_of_month v = v.day_of_month
let get_month v = v.month
let get_year v = v.year

let to_iso8601 v =
  Printf.sprintf "%04d-%02d-%02d" v.year v.month v.day_of_month
