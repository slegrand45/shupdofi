module Action = Shupdofi_clt_model.Action
module Block = Shupdofi_clt_model.Block
module Com = Shupdofi_com
module Modal = Shupdofi_clt_model.Modal
module Model = Shupdofi_clt_model.Model
module Msg_from_srv = Shupdofi_msg_clt_from_srv
module Msg_to_srv = Shupdofi_msg_clt_to_srv
module Routing = Shupdofi_clt_routing

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
  | Action.New_directory_ask_dirname ->
    let area_id = Com.Area_content.get_id m.Model.area_content in
    let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let modal = Modal.set_new_directory m.modal
                |> Modal.set_title "New directory"
                |> Modal.set_input_content ""
                |> Modal.set_txt_bt_ok "Create"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.New_directory_start { area_id; area_subdirs })
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action.New_directory_start { area_id; area_subdirs } ->
    let dirname = Modal.get_input_content m.modal in
    let c = Js_toast.append_from_list ~l:[dirname] ~prefix_id:area_id ~fun_msg:(fun _ -> "New directory " ^ dirname)
        ~fun_cmd:(fun toast_id dirname -> Api.send (Action.New_directory { area_id; area_subdirs; toast_id; dirname }))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action.New_directory { area_id; area_subdirs; toast_id; dirname } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.New_directory.make ~area_id ~subdirs:area_subdirs ~dirname
                  |> Msg_to_srv.New_directory.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) New_directory) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.New_directory_done { toast_id; status; json; dirname })] in
    return m ~c
  | Action.New_directory_done { toast_id; status; json; dirname } ->
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


  | Rename_directory_ask_dirname { directory } ->
    return m
  | Delete_directory_ask_confirm { directory } ->
    return m


  | Action.Delete_file_ask_confirm { file } ->
    let area_id = Com.Area_content.get_id m.Model.area_content in
    let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let filename = Com.File.get_name file in
    let msg = Printf.sprintf "I understand that the file \"%s\" will be permanently deleted." filename in
    let modal = Modal.set_confirm_delete msg m.modal
                |> Modal.set_input_switch false
                |> Modal.disable_bt_ok
                |> Modal.set_title "Delete file"
                |> Modal.set_input_content ""
                |> Modal.set_txt_bt_ok "Delete"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.Delete_file_start { area_id; area_subdirs; filename })
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action.Delete_file_start { area_id; area_subdirs; filename } ->
    let c = Js_toast.append_from_list ~l:[filename] ~prefix_id:area_id ~fun_msg:(fun _ -> "Delete file " ^ filename)
        ~fun_cmd:(fun toast_id dirname -> Api.send (Action.Delete_file { area_id; area_subdirs; toast_id; filename }))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action.Delete_file { area_id; area_subdirs; toast_id; filename } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Delete_file.make ~area_id ~subdirs:area_subdirs ~filename
                  |> Msg_to_srv.Delete_file.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Delete_file) in
    let c = [Api.http_delete ~url ~payload (fun status _ -> Action.Delete_file_done { area_id; area_subdirs; toast_id; filename; status })] in
    return m ~c
  | Action.Delete_file_done { area_id; area_subdirs; toast_id; filename; status } ->
    let m =
      match status with
      | 200 ->
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0;
        { m with area_content = Com.Area_content.(remove_file ~id:area_id ~subdirs:area_subdirs ~filename:filename m.area_content |> sort) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to delete file " ^ filename);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
  | Rename_file_ask_filename { file } ->
    let area_id = Com.Area_content.get_id m.Model.area_content in
    let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let old_filename = Com.File.get_name file in
    let modal = Modal.set_new_directory m.modal
                |> Modal.set_title "Rename file"
                |> Modal.set_input_content old_filename
                |> Modal.set_txt_bt_ok "Rename"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.Rename_file_start { area_id; area_subdirs; old_filename })
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Rename_file_start { area_id; area_subdirs; old_filename } ->
    let new_filename = Modal.get_input_content m.modal in
    let c = Js_toast.append_from_list ~l:[new_filename] ~prefix_id:area_id ~fun_msg:(fun _ -> "Rename file " ^ old_filename ^ " to " ^ new_filename)
        ~fun_cmd:(fun toast_id new_filename -> Api.send (Action.Rename_file { area_id; area_subdirs; toast_id; old_filename; new_filename }))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Rename_file { area_id; area_subdirs; toast_id; old_filename; new_filename } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Rename_file.make ~area_id ~subdirs:area_subdirs ~old_filename ~new_filename
                  |> Msg_to_srv.Rename_file.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Rename_file) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.Rename_file_done { toast_id; old_filename; new_filename; status; json })] in
    return m ~c
  | Rename_file_done { toast_id; old_filename; new_filename; status; json } ->
    let m =
      match status with
      | 200 ->
        let file_renamed = Yojson.Safe.from_string json |> Msg_from_srv.File_renamed.t_of_yojson in
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0;
        let area_id = Msg_from_srv.File_renamed.get_area_id file_renamed in
        let subdirs = Msg_from_srv.File_renamed.get_subdirs file_renamed in
        let old_file = Msg_from_srv.File_renamed.get_old_file file_renamed in
        let new_file = Msg_from_srv.File_renamed.get_new_file file_renamed in
        { m with area_content = Com.Area_content.(rename_file ~id:area_id ~subdirs ~old_file ~new_file m.area_content |> sort) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to rename file " ^ old_filename ^ " to " ^ new_filename);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
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