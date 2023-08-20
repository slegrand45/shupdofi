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

open Vdom
open Js_browser
open Js_of_ocaml

let update m a =
  match a with
  | Action_other.Delete_file.Ask { file } ->
    let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let filename = Com.File.get_name file in
    let msg = Printf.sprintf "I understand that the file \"%s\" will be permanently deleted." filename in
    let modal = Modal.set_confirm_delete msg m.modal
                |> Modal.set_input_switch false
                |> Modal.disable_bt_ok
                |> Modal.set_title "Delete file"
                |> Modal.set_input_content ""
                |> Modal.set_txt_bt_ok "Delete"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.Delete_file (Action_other.Delete_file.Start { area_id; subdirs; filename }))
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action_other.Delete_file.Start { area_id; subdirs; filename } ->
    let c = Js_toast.append_from_list ~l:[filename] ~prefix_id:area_id ~fun_msg:(fun _ -> "Delete file " ^ filename)
        ~fun_cmd:(fun toast_id dirname -> Api.send (Action.Delete_file (Action_other.Delete_file.Do { area_id; subdirs; toast_id; filename })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.Delete_file.Do { area_id; subdirs; toast_id; filename } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Delete_file.make ~area_id ~subdirs:subdirs ~filename
                  |> Msg_to_srv.Delete_file.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Delete_file) in
    let c = [Api.http_delete ~url ~payload (fun status _ -> Action.Delete_file (Action_other.Delete_file.Done { area_id; subdirs; toast_id; filename; status }))] in
    return m ~c
  | Action_other.Delete_file.Done { area_id; subdirs; toast_id; filename; status } ->
    let m =
      match status with
      | 200 ->
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:("File " ^ filename ^ " deleted");
        { m with area_content = Com.Area_content.(remove_file ~id:area_id ~subdirs:subdirs ~filename:filename m.area_content) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to delete file " ^ filename);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m