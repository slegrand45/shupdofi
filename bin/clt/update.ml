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
    (* Js_of_ocaml.Firebug.console##log ("click " ^ url); *)
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
    return m ~c:[Api.http_get ~url:(Routing.Api.(to_url (Block.Fetchable.route_api block))) ~payload:"" (fun r -> Action.Fetched (block, r))]
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
          let () = Random.self_init () in
          let document = Dom_html.window##.document in
          let container = Js.Opt.get (document##getElementById (Js.string "toast-container")) (fun () -> assert false) in
          let (elts, c) = List.fold_left (
              fun (elts, c) file ->
                let rnd = Random.int 1000000000 in
                let toast_id = "toast-" ^ area_id ^ "-" ^ (Int.to_string rnd) in
                let name = File.name file in
                let elts = (Js_toast.html ~doc:Dom_html.document ~id:toast_id ~msg:name)::elts in
                let c = (Api.send (Action.Upload_file (area_id, area_subdirs, toast_id, file))) :: c in
                (elts, c)
            ) ([], []) files
          in
          let () = List.iter (fun e -> Dom.appendChild container e) elts in
          return m ~c
        )
    )
  | Action.Upload_file (area_id, area_subdirs, toast_id, file) -> (
      let elt = Document.get_element_by_id document toast_id in
      let toast = Option.bind elt (fun e -> Some (Js_toast.getOrCreateInstance e)) in
      let () = Option.iter (fun e -> e##show()) toast in
      let name = File.name file in
      let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Upload(area_id, area_subdirs, name))) in
      let c = [Api.http_post_file ~url ~file (fun status response -> Action.Uploaded_file (toast_id, status, response))] in
      return m ~c
    )
  | Action.Uploaded_file (toast_id, status, json) -> (
      let uploaded = Yojson.Safe.from_string json |> Com.Uploaded.t_of_yojson in
      let m = { m with area_content = Com.Area_content.(add_uploaded uploaded m.area_content |> sort) } in
      (* clean hidden toasts *)
      let container = Dom_html.getElementById "toast-container" in
      let elements = container##querySelectorAll (Js.string ".toast.hide") in
      let () = elements |> Dom.list_of_nodeList |> List.iter (fun e ->
          let id = Js.Opt.get (e##getAttribute (Js.string "id")) (fun () -> assert false) in
          let elt = Document.get_element_by_id document (Js.to_string id) in
          let toast = Option.bind elt (fun e -> Some (Js_toast.getInstance e)) in
          Option.iter (fun e -> e##dispose()) toast;
          e##.outerHTML := (Js.string "")
        ) in
      (* change toast status *)
      let () = match status with
        | 201 -> Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0
        | _ -> Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:"Unable to upload file"
      in
      return m
    )

  | Action.New_directory_start ->
    let () = prerr_endline "New directory start" in
    let area_id = Com.Area_content.get_id m.Model.area_content in
    let area_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let modal = Modal.set_title "New directory" m.modal
                |> Modal.set_input_content "..."
                |> Modal.set_txt_bt_ok "Create"
                |> Modal.set_txt_bt_cancel "Cancel"
                |> Modal.set_fun_bt_ok (fun e -> Action.New_directory (area_id, area_subdirs))
    in
    let m = { m with modal } in
    let () = Js_modal.show () in
    return m
  | Action.New_directory (area_id, area_subdirs) ->
    let () = prerr_endline "New_directory" in
    let () = prerr_endline area_id in
    return m
  | Action.Modal_set_input_content content ->
    return { m with modal = Modal.set_input_content content m.modal }
  | Action.Modal_close ->
    let () = Js_modal.hide () in
    return m
  | Action.Modal_cancel ->
    let () = Js_modal.hide () in
    return m
    (*
  | Action.Modal_ok ->
    let () = Js_modal.hide () in
    return m
*)
