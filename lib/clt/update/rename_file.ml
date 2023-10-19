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
  | Action_other.Rename_file.Ask { file } ->
    let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let old_filename = Com.File.get_name file in
    let fun_ok = (fun _ -> Action.Rename_file (Action_other.Rename_file.Start { area_id; subdirs; old_filename })) in
    let modal = Modal.set_new_entry m.modal
                |> Modal.set_title (T._t prefs Rename_file)
                |> Modal.enable_bt_ok
                |> Modal.set_input_content old_filename
                |> Modal.set_txt_bt_ok (T._t prefs Rename)
                |> Modal.set_txt_bt_cancel (T._t prefs Cancel)
                |> Modal.set_fun_bt_ok fun_ok
                |> Modal.set_fun_kb_ok fun_ok
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action_other.Rename_file.Start { area_id; subdirs; old_filename } ->
    let new_filename = Modal.get_input_content m.modal in
    let c_default = Api.send(Action.Modal_close) in
    if old_filename <> new_filename then
      let c = Js_toast.append_from_list ~l:[new_filename] ~prefix_id:area_id ~fun_msg:(fun _ -> (T._t prefs (Rename_file_old_new (old_filename, new_filename))))
          ~fun_cmd:(fun toast_id new_filename -> Api.send (Action.Rename_file (Action_other.Rename_file.Do { area_id; subdirs; toast_id; old_filename; new_filename })))
      in
      let c = c_default :: c in
      return m ~c
    else
      return m ~c:[c_default]
  | Action_other.Rename_file.Do { area_id; subdirs; toast_id; old_filename; new_filename } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Rename_file.make ~area_id ~subdirs:subdirs ~old_filename ~new_filename
                  |> Msg_to_srv.Rename_file.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Rename_file) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.Rename_file (Action_other.Rename_file.Done { toast_id; old_filename; new_filename; status; json }))] in
    return m ~c
  | Action_other.Rename_file.Done { toast_id; old_filename; new_filename; status; json } ->
    let m =
      match status with
      | 200 ->
        let file_renamed = Yojson.Safe.from_string json |> Msg_from_srv.File_renamed.t_of_yojson in
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:(T._t prefs (File_renamed_old_new (old_filename, new_filename)));
        let area_id = Msg_from_srv.File_renamed.get_area_id file_renamed in
        let subdirs = Msg_from_srv.File_renamed.get_subdirs file_renamed in
        let old_file = Msg_from_srv.File_renamed.get_old_file file_renamed in
        let new_file = Msg_from_srv.File_renamed.get_new_file file_renamed in
        { m with area_content = Com.Area_content.(rename_file ~id:area_id ~subdirs ~old_file ~new_file m.area_content) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:(T._t prefs (Unable_to_rename_file_old_new (old_filename, new_filename)));
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m