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
  | Action_other.Selection.Clear { area; subdirs } ->
    let selection = Com.Selection.clear ~area ~subdirs m.Model.selection in
    let m = { m with selection } in
    return m
