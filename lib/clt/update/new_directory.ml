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
  | Action_other.New_directory.Ask ->
    let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let modal = Modal.set_new_entry m.modal
                |> Modal.enable_bt_ok
                |> Modal.set_title "New directory"
                |> Modal.set_input_content ""
                |> Modal.set_txt_bt_ok "Create"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.New_directory (Action_other.New_directory.Start { area_id; area_subdirs }))
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action_other.New_directory.Start { area_id; area_subdirs } ->
    let dirname = Modal.get_input_content m.modal in
    let c = Js_toast.append_from_list ~l:[dirname] ~prefix_id:area_id ~fun_msg:(fun _ -> "Directory " ^ dirname ^ " created")
        ~fun_cmd:(fun toast_id dirname -> Api.send (Action.New_directory (Action_other.New_directory.Do { area_id; area_subdirs; toast_id; dirname })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.New_directory.Do { area_id; area_subdirs; toast_id; dirname } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.New_directory.make ~area_id ~subdirs:area_subdirs ~dirname
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
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0;
        let area_id = Msg_from_srv.New_directory_created.get_area_id new_directory in
        let subdirs = Msg_from_srv.New_directory_created.get_subdirs new_directory in
        let directory = Msg_from_srv.New_directory_created.get_directory new_directory in
        { m with area_content = Com.Area_content.(add_new_directory ~id:area_id ~subdirs ~directory m.area_content |> sort) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to create new directory " ^ dirname);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m