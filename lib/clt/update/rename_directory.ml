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
  | Action_other.Rename_directory.Ask { directory } ->
    let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let old_dirname = Com.Directory.get_name directory in
    let modal = Modal.set_new_entry m.modal
                |> Modal.set_title "Rename directory"
                |> Modal.enable_bt_ok
                |> Modal.set_input_content old_dirname
                |> Modal.set_txt_bt_ok "Rename"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.Rename_directory (Action_other.Rename_directory.Start { area_id; subdirs; old_dirname }))
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action_other.Rename_directory.Start { area_id; subdirs; old_dirname } ->
    let new_dirname = Modal.get_input_content m.modal in
    let c_default = Api.send(Action.Modal_close) in
    if old_dirname <> new_dirname then
      let c = Js_toast.append_from_list ~l:[new_dirname] ~prefix_id:area_id ~fun_msg:(fun _ -> "Rename " ^ old_dirname ^ " to " ^ new_dirname)
          ~fun_cmd:(fun toast_id new_dirname -> Api.send (Action.Rename_directory (Action_other.Rename_directory.Do { area_id; subdirs; toast_id; old_dirname; new_dirname })))
      in
      let c = c_default :: c in
      return m ~c
    else
      return m ~c:[c_default]
  | Action_other.Rename_directory.Do { area_id; subdirs; toast_id; old_dirname; new_dirname } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Rename_directory.make ~area_id ~subdirs:subdirs ~old_dirname ~new_dirname
                  |> Msg_to_srv.Rename_directory.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Rename_directory) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.Rename_directory (Action_other.Rename_directory.Done { toast_id; old_dirname; new_dirname; status; json }))] in
    return m ~c
  | Action_other.Rename_directory.Done { toast_id; old_dirname; new_dirname; status; json } ->
    let m =
      match status with
      | 200 ->
        let directory_renamed = Yojson.Safe.from_string json |> Msg_from_srv.Directory_renamed.t_of_yojson in
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:(old_dirname ^ " renamed to " ^ new_dirname);
        let area_id = Msg_from_srv.Directory_renamed.get_area_id directory_renamed in
        let subdirs = Msg_from_srv.Directory_renamed.get_subdirs directory_renamed in
        let old_directory = Msg_from_srv.Directory_renamed.get_old_directory directory_renamed in
        let new_directory = Msg_from_srv.Directory_renamed.get_new_directory directory_renamed in
        { m with area_content = Com.Area_content.(rename_directory ~id:area_id ~subdirs ~old_directory ~new_directory m.area_content) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to rename directory " ^ old_dirname ^ " to " ^ new_dirname);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
