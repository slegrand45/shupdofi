module Action = Shupdofi_clt_model.Action
module Api = Shupdofi_clt_api.Api
module Model = Shupdofi_clt_model.Model

open Vdom
open Js_browser

let update = Update.update

let init =
  return Model.empty ~c:[Api.send Action.Current_url_modified]

let () = Vdom_blit.(register (cmd {f = Api.cmd_handler}))

let app = Vdom.app ~init ~update ~view:View.view ()
let app = Vdom_blit.run app

let () = Window.add_event_listener window Event.Popstate
    (fun _ -> Vdom_blit.process app Action.Current_url_modified) false

let run () =
  (* Js_of_ocaml.Firebug.console##log ((Location.pathname (Window.location window))); *)
  Vdom_blit.dom app |> Element.append_child (Document.body document)

let () = Window.set_onload window run