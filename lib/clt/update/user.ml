module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
module Api = Shupdofi_clt_api.Api
module Com = Shupdofi_com
module Js_toast = Shupdofi_clt_js.Toast
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing

open Vdom
open Js_browser
open Js_of_ocaml

let update m a =
  match a with
  | Action_other.User.Do ->
    return m ~c:[Api.http_get ~url:(Routing.Api.(to_url User)) ~payload:"" (fun status json -> Action.User (Action_other.User.Done { status; json }))]
  | Action_other.User.Done { status; json } -> (
      match status with
      | 200 ->
        let m = { m with Model.user = Yojson.Safe.from_string json |> Com.User.t_of_yojson } in
        return m
      | _ ->
        let area_id = Com.Area_content.get_area m.area_content |> Com.Area.get_id in
        let c = Js_toast.append_from_list ~l:[true] ~prefix_id:area_id ~fun_msg:(fun _ -> "")
            ~fun_cmd:(fun toast_id _ -> Api.send (Action.User (Action_other.User.Error { toast_id; msg = json }))) in
        return m ~c
    )
  | Action_other.User.Error { toast_id; msg } -> (
      Js_toast.(
        clean_hiddens ~document;
        set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg;
        show ~document ~toast_id;
      );
      return m
    )