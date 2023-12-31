module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
module Api = Shupdofi_clt_api.Api
module Com = Shupdofi_com
module Js_modal = Shupdofi_clt_js.Modal
module Js_toast = Shupdofi_clt_js.Toast
module Model = Shupdofi_clt_model.Model
module Modal = Shupdofi_clt_model.Modal
module Msg_from_srv = Shupdofi_msg_clt_from_srv
module Msg_to_srv = Shupdofi_msg_clt_to_srv
module Routing = Shupdofi_clt_routing
module T = Shupdofi_clt_i18n.T

open Vdom
open Js_browser
open Js_of_ocaml

let update m a =
  let prefs = m.Model.preferences in
  match a with
  | Action_other.New_directory.Ask ->
    let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let fun_ok = (fun _ -> Action.New_directory (Action_other.New_directory.Start { area_id; subdirs })) in
    let modal = Modal.set_new_entry m.modal
                |> Modal.enable_bt_ok
                |> Modal.set_title (T._t prefs New_directory)
                |> Modal.set_input_content ""
                |> Modal.set_txt_bt_ok (T._t prefs Create)
                |> Modal.set_txt_bt_cancel (T._t prefs Cancel)
                |> Modal.set_fun_bt_ok fun_ok
                |> Modal.set_fun_kb_ok fun_ok
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action_other.New_directory.Start { area_id; subdirs } ->
    let dirname = Modal.get_input_content m.modal in
    let c = Js_toast.append_from_list ~l:[dirname] ~prefix_id:area_id ~fun_msg:(fun _ -> (T._t prefs (Create_directory dirname)))
        ~fun_cmd:(fun toast_id dirname -> Api.send (Action.New_directory (Action_other.New_directory.Do { area_id; subdirs; toast_id; dirname })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.New_directory.Do { area_id; subdirs; toast_id; dirname } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.New_directory.make ~area_id ~subdirs:subdirs ~dirname
                  |> Msg_to_srv.New_directory.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) New_directory) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.New_directory (Action_other.New_directory.Done { toast_id; status; json; dirname }))] in
    return m ~c
  | Action_other.New_directory.Done { toast_id; status; json; dirname } ->
    let m =
      match status with
      | 201 ->
        let new_directory = Yojson.Safe.from_string json |> Msg_from_srv.New_directory_created.t_of_yojson in
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:(T._t prefs (Directory_created dirname));
        let area_id = Msg_from_srv.New_directory_created.get_area_id new_directory in
        let subdirs = Msg_from_srv.New_directory_created.get_subdirs new_directory in
        let directory = Msg_from_srv.New_directory_created.get_directory new_directory in
        { m with area_content = Com.Area_content.(add_new_directory ~id:area_id ~subdirs ~directory m.area_content) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:(T._t prefs (Unable_to_create_directory dirname));
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m