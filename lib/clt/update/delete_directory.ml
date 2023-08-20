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
  | Action_other.Delete_directory.Ask { directory } ->
    let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let dirname = Com.Directory.get_name directory in
    let msg = Printf.sprintf "I understand that the directory \"%s\" and all its contents will be permanently deleted." dirname in
    let modal = Modal.set_confirm_delete msg m.modal
                |> Modal.set_input_switch false
                |> Modal.disable_bt_ok
                |> Modal.set_title "Delete directory"
                |> Modal.set_input_content ""
                |> Modal.set_txt_bt_ok "Delete"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.Delete_directory (Action_other.Delete_directory.Start { area_id; subdirs; dirname }))
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action_other.Delete_directory.Start { area_id; subdirs; dirname } ->
    let c = Js_toast.append_from_list ~l:[dirname] ~prefix_id:area_id ~fun_msg:(fun _ -> "Delete directory " ^ dirname)
        ~fun_cmd:(fun toast_id dirname -> Api.send (Action.Delete_directory (Action_other.Delete_directory.Do { area_id; subdirs; toast_id; dirname })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.Delete_directory.Do { area_id; subdirs; toast_id; dirname } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Delete_directory.make ~area_id ~subdirs:subdirs ~dirname
                  |> Msg_to_srv.Delete_directory.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Delete_directory) in
    let c = [Api.http_delete ~url ~payload (fun status _ -> Action.Delete_directory (Action_other.Delete_directory.Done { area_id; subdirs; toast_id; dirname; status }))] in
    return m ~c
  | Action_other.Delete_directory.Done { area_id; subdirs; toast_id; dirname; status } ->
    let m =
      match status with
      | 200 ->
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:("Directory " ^ dirname ^ " deleted");
        { m with area_content = Com.Area_content.(remove_directory ~id:area_id ~subdirs:subdirs ~dirname:dirname m.area_content) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to delete directory " ^ dirname);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m