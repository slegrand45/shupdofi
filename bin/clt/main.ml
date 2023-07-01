module Action = Shupdofi_clt_model.Action
module Model = Shupdofi_clt_model.Model

open Vdom
open Js_browser

let update = Update.update

let init =
  (* let route = Shupdofi_clt.Router.from_pathname (Location.pathname (Window.location window)) in *)
  return (* (Shupdofi_clt.Model.set_route route *) Model.empty ~c:[Api.send Action.Current_url_modified]

(* let button txt msg = input [] ~a:[onclick (fun _ -> msg); type_button; value txt] *)

(*
let view { counters } =
  let row (pos, value) =
    div [button "-" (`Update (pos, -1)); text (string_of_int value); button "+" (`Update (pos, 1));]
  in
  div (
    div [
      button "New counter" `New_counter; 
      Shupdofi_clt.Html.input_file "fileinput"
        (fun _ -> Js_browser.(Console.log console (JsString.(t_to_js(of_string ("clic"))))); `Toto)
        (fun _ -> Js_browser.(Console.log console (JsString.(t_to_js(of_string ("input"))))); `Toto)
        (fun e ->
          Js_browser.(Console.log console (JsString.(t_to_js(of_string ("xxxx" ^ e)))));
          `ChangeFile "fileinput"
        );
    ] :: (IntMap.bindings counters |> List.map row)
  )
  *)

let view = View.view


let () = Vdom_blit.(register (cmd {f = Api.cmd_handler}))

let app = Vdom.app ~init ~update ~view ()
let app = Vdom_blit.run app

let () = Window.add_event_listener window Event.Popstate
    (fun _ -> Vdom_blit.process app Action.Current_url_modified) false

let run () =
  (* Js_of_ocaml.Firebug.console##log ((Location.pathname (Window.location window))); *)
  Vdom_blit.dom app |> Element.append_child (Document.body document)

let () = Window.set_onload window run