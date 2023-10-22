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
  | Action_other.Upload_file.Start { input_file_id } -> (
      let input_file = Document.get_element_by_id document input_file_id in
      match input_file with
      | None -> return m
      | Some e -> (
          let area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
          let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
          let files = Element.files e in
          let c = Js_toast.append_from_list ~l:files ~prefix_id:area_id ~fun_msg:(fun e -> (T._t prefs (Upload_filename (Js_browser.File.name e))))
              ~fun_cmd:(fun toast_id file -> Api.send (Action.Upload_file (Action_other.Upload_file.Do { area_id; subdirs; toast_id; file }))) in
          return m ~c
        )
    )
  | Action_other.Upload_file.Do { area_id; subdirs; toast_id; file } -> (
      let () = Js_toast.show ~document ~toast_id in
      let filename = Js_browser.File.name file in
      let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Upload { area_id; subdirs; filename })) in
      let c = [Api.http_post_file ~url ~file (fun status txt -> Action.Upload_file (Action_other.Upload_file.Done { toast_id; status; txt; filename }))] in
      return m ~c
    )
  | Action_other.Upload_file.Done { toast_id; status; txt; filename } -> (
      let m =
        match status with
        | 201 ->
          let uploaded = Yojson.Safe.from_string txt |> Msg_from_srv.Uploaded.t_of_yojson in
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:(T._t prefs (File_uploaded filename));
          let area_id = Msg_from_srv.Uploaded.get_area_id uploaded in
          let subdirs = Msg_from_srv.Uploaded.get_subdirs uploaded in
          let file = Msg_from_srv.Uploaded.get_file uploaded in
          { m with area_content = Com.Area_content.(add_uploaded ~id:area_id ~subdirs ~file m.area_content) }
        | _ ->
          let msg =
            match txt with
            | "" -> (T._t prefs (Unable_to_upload_file filename))
            | _ -> (T._t prefs (Unable_to_upload_file_with_additional_txt (filename, txt)))
          in
          Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg;
          m
      in
      let () = Js_toast.clean_hiddens ~document in
      return m
    )