module Action = Shupdofi_clt_model.Action
module Block = Shupdofi_clt_model.Block
module Com = Shupdofi_com
module Modal = Shupdofi_clt_model.Modal
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing

open Vdom
open Js_of_ocaml
open Js_browser

let update m a =
  match a with
  | Action.Nothing ->
    return m
  | Action.Set_current_url url ->
    let () = Js_browser.(History.push_state (Window.history window) (Ojs.string_to_js "") "" url) in
    return m ~c:[Api.send Action.Current_url_modified]
  | Action.Current_url_modified -> (
      let route = Routing.Router.from_pathname (Location.pathname (Window.location window)) in
      let m = Model.set_route route m in
      (* fetch de tous les blocs de la page *)
      match route with
      | Home
      | Areas -> return m ~c:[Api.send (Action.Fetch_start Block.Fetchable.areas)]
      | Area_content (id, subdirs) ->
        let area_content = m.Model.area_content
                           |> Com.Area_content.set_id id
                           |> Com.Area_content.set_subdirs subdirs
        in
        let m = { m with area_content } in
        return m ~c:[Api.send (Action.Fetch_start (Block.Fetchable.area_content id subdirs))]
    )
  | Action.Fetch_start block ->
    let m = { m with block = Block.Fetchable.to_loading block } in
    return m ~c:[Api.send (Action.Fetch block)]
  | Action.Fetch block ->
    return m ~c:[Api.http_get ~url:(Routing.Api.(to_url (Block.Fetchable.route_api block))) ~payload:"" (fun _ r -> Action.Fetched (block, r))]
  | Action.Fetched (block, json) ->
    let m = { m with block = Block.Fetchable.to_loaded block } in
    let m =
      match Block.Fetchable.get_id block with
      | Block.Fetchable.Areas -> { m with areas = Yojson.Safe.from_string json |> Com.Area.collection_of_yojson }
      | Block.Fetchable.Area_content _ -> { m with area_content = Yojson.Safe.from_string json |> Com.Area_content.t_of_yojson }
      | _ -> m
    in
    return m
  | Action.Area_go_to_subdir name ->
    let id = Com.Area_content.get_id m.Model.area_content in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let new_subdirs = subdirs @ [name] in
    let route = Routing.Page.Area_content (id, new_subdirs) in
    let url = Routing.Page.to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) route in
    return { m with area_content = (Com.Area_content.set_subdirs new_subdirs m.Model.area_content) }
      ~c:[Api.send (Action.Set_current_url url)]
  | Action.Upload_file_start id -> (
      let input_file = Document.get_element_by_id document id in
      match input_file with
      | None -> return m
      | Some e -> (
          let area_id = Com.Area_content.get_id m.Model.area_content in
          let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
          let files = Element.files e in
          let c = Js_toast.append_from_list ~l:files ~prefix_id:area_id ~fun_msg:File.name
              ~fun_cmd:(fun toast_id e -> Api.send (Action.Upload_file (area_id, area_subdirs, toast_id, e))) in
          return m ~c
        )
    )
  | Action.Upload_file (area_id, area_subdirs, toast_id, file) -> (
      let () = Js_toast.show ~document ~toast_id in
      let name = File.name file in
      let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Upload(area_id, area_subdirs, name))) in
      let c = [Api.http_post_file ~url ~file (fun status response -> Action.Uploaded_file (toast_id, status, response, name))] in
      return m ~c
    )
  | Action.Uploaded_file (toast_id, status, json, filename) -> (
      let m =
        match status with
        | 201 ->
          let uploaded = Yojson.Safe.from_string json |> Com.Uploaded.t_of_yojson in
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0;
          { m with area_content = Com.Area_content.(add_uploaded uploaded m.area_content |> sort) }
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
    let modal = Modal.set_title "New directory" m.modal
                |> Modal.set_input_content "..."
                |> Modal.set_txt_bt_ok "Create"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.New_directory_start (area_id, area_subdirs))
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action.New_directory_start (area_id, area_subdirs) ->
    let dirname = Modal.get_input_content m.modal in
    let c = Js_toast.append_from_list ~l:[dirname] ~prefix_id:area_id ~fun_msg:(fun _ -> "New directory " ^ dirname)
        ~fun_cmd:(fun toast_id e -> Api.send (Action.New_directory (area_id, area_subdirs, toast_id, e)))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action.New_directory (area_id, area_subdirs, toast_id, dirname) ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Com.New_directory.make ~area_id ~subdirs:area_subdirs ~dirname
                  |> Com.New_directory.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) New_directory) in
    let c = [Api.http_post ~url ~payload (fun status response -> Action.New_directory_created (toast_id, status, response, dirname))] in
    return m ~c
  | Action.New_directory_created (toast_id, status, json, dirname) ->
    let m =
      match status with
      | 201 ->
        let new_directory = Yojson.Safe.from_string json |> Com.New_directory_created.t_of_yojson in
        Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0;
        { m with area_content = Com.Area_content.(add_new_directory new_directory m.area_content |> sort) }
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to create new directory " ^ dirname);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
  | Action.Modal_set_input_content content ->
    return { m with modal = Modal.set_input_content content m.modal }
  | Action.Modal_close ->
    let () = Js_modal.hide () in
    return m
  | Action.Modal_cancel ->
    let () = Js_modal.hide () in
    return m