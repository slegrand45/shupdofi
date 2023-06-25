type t = {
  date: Date.t;
  time: Time.t;
}
[@@deriving yojson]

let make ~date ~time =
  { date; time }

let get_date v = v.date

let get_time v = v.time

let to_string v =
  Printf.sprintf "%s %s" (Date.to_string v.date) (Time.to_string v.time)

let to_date_hm v =
  Printf.sprintf "%s %s" (Date.to_string v.date) (Time.to_hm v.time)
