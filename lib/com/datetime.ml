type t = {
  date: Date.t;
  time: Time.t;
}
[@@deriving yojson]

let make ~date ~time =
  { date; time }

let get_date v = v.date

let get_time v = v.time

let to_iso8601 v =
  Printf.sprintf "%s %s" (Date.to_iso8601 v.date) (Time.to_iso8601 v.time)
