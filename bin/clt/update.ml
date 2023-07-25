module Action = Shupdofi_clt_model.Action
module Api = Shupdofi_clt_api.Api
module Block = Shupdofi_clt_model.Block
module Com = Shupdofi_com
module Js_modal = Shupdofi_clt_js.Modal
module Js_toast = Shupdofi_clt_js.Toast
module Modal = Shupdofi_clt_model.Modal
module Model = Shupdofi_clt_model.Model
module Msg_from_srv = Shupdofi_msg_clt_from_srv
module Msg_to_srv = Shupdofi_msg_clt_to_srv
module Routing = Shupdofi_clt_routing
module Update_other = Shupdofi_clt_update

open Vdom
open Js_of_ocaml
open Js_browser

let update m a =
  match a with
  | Action.Nothing ->
    return m
  | Action.Set_current_url { url } ->
    let () = Js_browser.(History.push_state (Window.history window) (Ojs.string_to_js "") "" url) in
    return m ~c:[Api.send Action.Current_url_modified]
  | Action.Current_url_modified -> (
      let route = Routing.Router.from_pathname (Location.pathname (Window.location window)) in
      let m = Model.set_route route m in
      (* fetch de tous les blocs de la page *)
      match route with
      | Home
      | Areas -> return m ~c:[Api.send (Action.Fetch_start { block = Block.Fetchable.areas })]
      | Area_content (id, subdirs) ->
        let area_content = m.Model.area_content
                           |> Com.Area_content.set_id id
                           |> Com.Area_content.set_subdirs subdirs
        in
        let m = { m with area_content } in
        return m ~c:[Api.send (Action.Fetch_start { block = (Block.Fetchable.area_content id subdirs) })]
    )
  | Action.Fetch_start { block } ->
    let m = { m with block = Block.Fetchable.to_loading block } in
    return m ~c:[Api.send (Action.Fetch { block })]
  | Action.Fetch { block } ->
    return m ~c:[Api.http_get ~url:(Routing.Api.(to_url (Block.Fetchable.route_api block))) ~payload:"" (fun _ json -> Action.Fetched { block; json })]
  | Action.Fetched { block; json } ->
    let m = { m with block = Block.Fetchable.to_loaded block } in
    let m =
      match Block.Fetchable.get_id block with
      | Block.Fetchable.Areas -> { m with areas = Yojson.Safe.from_string json |> Com.Area.collection_of_yojson }
      | Block.Fetchable.Area_content _ -> { m with area_content = Yojson.Safe.from_string json |> Com.Area_content.t_of_yojson }
      | _ -> m
    in
    return m
  | Action.Area_go_to_subdir { name } ->
    let id = Com.Area_content.get_id m.Model.area_content in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let new_subdirs = subdirs @ [name] in
    let route = Routing.Page.Area_content (id, new_subdirs) in
    let url = Routing.Page.to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) route in
    return { m with area_content = (Com.Area_content.set_subdirs new_subdirs m.Model.area_content) }
      ~c:[Api.send (Action.Set_current_url { url })]
  | Action.Upload_file_start { input_file_id } -> (
      let input_file = Document.get_element_by_id document input_file_id in
      match input_file with
      | None -> return m
      | Some e -> (
          let area_id = Com.Area_content.get_id m.Model.area_content in
          let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
          let files = Element.files e in
          let c = Js_toast.append_from_list ~l:files ~prefix_id:area_id ~fun_msg:File.name
              ~fun_cmd:(fun toast_id file -> Api.send (Action.Upload_file { area_id; area_subdirs; toast_id; file })) in
          return m ~c
        )
    )
  | Action.Upload_file { area_id; area_subdirs; toast_id; file } -> (
      let () = Js_toast.show ~document ~toast_id in
      let filename = File.name file in
      let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Upload { area_id; area_subdirs; filename })) in
      let c = [Api.http_post_file ~url ~file (fun status json -> Action.Uploaded_file { toast_id; status; json; filename })] in
      return m ~c
    )
  | Action.Uploaded_file { toast_id; status; json; filename } -> (
      let m =
        match status with
        | 201 ->
          let uploaded = Yojson.Safe.from_string json |> Msg_from_srv.Uploaded.t_of_yojson in
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0;
          let area_id = Msg_from_srv.Uploaded.get_area_id uploaded in
          let subdirs = Msg_from_srv.Uploaded.get_subdirs uploaded in
          let file = Msg_from_srv.Uploaded.get_file uploaded in
          { m with area_content = Com.Area_content.(add_uploaded ~id:area_id ~subdirs ~file m.area_content |> sort) }
        | _ ->
          Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to upload file " ^ filename);
          m
      in
      let () = Js_toast.clean_hiddens ~document in
      return m
    )
  | Action.New_directory a -> Update_other.New_directory.update m a
  | Action.Rename_directory a -> Update_other.Rename_directory.update m a
  | Action.Delete_directory_ask_confirm { directory } ->
    return m
  | Action.Rename_file a -> Update_other.Rename_file.update m a
  | Action.Delete_file a -> Update_other.Delete_file.update m a
  | Action.Modal_set_input_content { content } ->
    return { m with modal = Modal.set_input_content content m.modal }
  | Action.Modal_toggle_switch ->
    let m = { m with modal = Modal.toggle_input_switch m.modal } in
    let m = match Modal.get_input_switch m.modal with
      | true -> { m with modal = Modal.enable_bt_ok m.modal }
      | false -> { m with modal = Modal.disable_bt_ok m.modal }
    in
    return m
  | Action.Modal_close ->
    let () = Js_modal.hide () in
    return m
  | Action.Modal_cancel ->
    let () = Js_modal.hide () in
    return m