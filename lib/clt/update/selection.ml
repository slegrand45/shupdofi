module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
module Api = Shupdofi_clt_api.Api
module Com = Shupdofi_com
module Js_toast = Shupdofi_clt_js.Toast
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing

open Vdom

let update m a =
  match a with
  | Action_other.Selection.Clear ->
    let selection = Com.Selection.clear m.Model.selection in
    let m = { m with selection } in
    return m
  | Action_other.Selection.Delete ->
    prerr_endline "DELETE";
    prerr_endline (Com.Selection.to_string m.selection);
    return m
