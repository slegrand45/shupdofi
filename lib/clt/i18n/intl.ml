module Com = Shupdofi_com

open Js_of_ocaml

type language = En | Fr

let language_from_string = function
  | "fr" -> Fr
  | _ -> En

let language_to_string = function
  | Fr -> "fr"
  | En -> "en"

let user_language () =
  (* From https://github.com/ocsigen/js_of_ocaml/blob/master/examples/hyperbolic/hypertree.ml *)
  let s = 
    Js.to_string (
      (Js.Optdef.get
         Dom_html.window##.navigator##.language
         (fun () ->
            Js.Optdef.get Dom_html.window##.navigator##.userLanguage (fun () -> Js.string "en")))
      ##substring
        0
        2)
  in
  language_from_string s

let fmt_date_hm lang dt =
  let year = Com.(Datetime.get_date dt |> Date.get_year) in
  let month = Com.(Datetime.get_date dt |> Date.get_month) in
  let day_of_month = Com.(Datetime.get_date dt |> Date.get_day_of_month) in
  let hour = Com.(Datetime.get_time dt |> Time.get_hour) in
  let minute = Com.(Datetime.get_time dt |> Time.get_minute) in
  let date_constr = Js.Unsafe.global##._Date in
  let s = Printf.sprintf "%04d-%02d-%02dT%02d:%02d:00.000Z" year month day_of_month hour minute in
  let date_obj = new%js date_constr s in
  let options = Intl.DateTimeFormat.options () in
  let () = options##.year := Js.def(Js.string "numeric") in
  let () = options##.month := Js.def(Js.string "numeric") in
  let () = options##.day := Js.def(Js.string "numeric") in
  let () = options##.hour := Js.def(Js.string "numeric") in
  let () = options##.minute := Js.def(Js.string "numeric") in
  let dtf = new%js Intl.dateTimeFormat_constr
    (Js.undefined) (Js.def options)
  in
  Js.to_string (dtf##.format date_obj)
