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
  | Action_other.Selection.Clear ->
    let selection = Com.Selection.empty in
    let m = Model.{ m with selection } in
    return m
  | Action_other.Selection.Delete_ask -> (
      match Com.Selection.get_area_content m.selection with
      | None ->
        return m
      | Some area_content ->
        let area_id = Com.Area_content.get_area area_content |> Com.Area.get_id in
        let subdirs = Com.Area_content.get_subdirs area_content in
        let dirnames = Com.Area_content.get_directories area_content |> List.map Com.Directory.get_name in
        let filenames = Com.Area_content.get_files area_content |> List.map Com.File.get_name in
        let msg = T._t prefs I_understand_all_selected_directories_files_definitively_deleted_dot in
        let fun_ok = (fun _ -> Action.Selection (Action_other.Selection.Delete_start { area_id; subdirs; dirnames; filenames })) in
        let modal = Modal.set_confirm_delete msg m.modal
                    |> Modal.set_input_switch false
                    |> Modal.disable_bt_ok
                    |> Modal.set_title (T._t prefs Delete_selection)
                    |> Modal.set_input_content ""
                    |> Modal.set_txt_bt_ok (T._t prefs Delete)
                    |> Modal.set_txt_bt_cancel (T._t prefs Cancel)
                    |> Modal.set_fun_bt_ok fun_ok
                    |> Modal.set_fun_kb_ok fun_ok
        in
        let m = { m with modal } in
        let () = Js_modal.show () in
        return m
    )
  | Action_other.Selection.Delete_start { area_id; subdirs; dirnames; filenames } ->
    let c = Js_toast.append_from_list ~l:[""] ~prefix_id:area_id ~fun_msg:(fun _ -> (T._t prefs Delete_selection))
        ~fun_cmd:(fun toast_id _ -> Api.send (Action.Selection (Action_other.Selection.Delete_do { toast_id; area_id; subdirs; dirnames; filenames })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.Selection.Delete_do { toast_id; area_id; subdirs; dirnames; filenames } ->
    let () = Js_toast.show ~document ~toast_id in
    let payload = Msg_to_srv.Selection.make ~area_id ~subdirs ~dirnames ~filenames
                  |> Msg_to_srv.Selection.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Delete_selection) in
    let c = [Api.http_delete ~url ~payload (fun status json -> Action.Selection (Action_other.Selection.Delete_done { toast_id; area_id; subdirs; status; json }))] in
    return m ~c
  | Action_other.Selection.Delete_done { toast_id; area_id; subdirs; status; json } ->
    let m =
      match status with
      | 200 -> (
          let result = Yojson.Safe.from_string json |> Msg_from_srv.Selection_processed.t_of_yojson in
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:(T._t prefs Selection_deleted);
          let area_content = List.fold_left (
              fun acc (e, _) -> Com.Area_content.(remove_directory ~id:area_id ~subdirs:subdirs ~dirname:(Com.Directory.get_name e) acc)
            ) m.area_content (Msg_from_srv.Selection_processed.get_directories_ok result)
          in
          let selection = List.fold_left (
              fun acc (e, _) -> Com.Selection.(remove_directory ~area_id ~subdirs:subdirs e acc)
            ) m.selection (Msg_from_srv.Selection_processed.get_directories_ok result)
          in
          let area_content = List.fold_left (
              fun acc (e, _) ->
                match (Com.Path.get_file e) with
                | Some file ->
                  Com.Area_content.(remove_file ~id:area_id ~subdirs:subdirs ~filename:(Com.File.get_name file) acc)
                | None ->
                  acc
            ) area_content (Msg_from_srv.Selection_processed.get_paths_ok result)
          in
          let selection = List.fold_left (
              fun acc (e, _) ->
                match (Com.Path.get_file e) with
                | Some file ->
                  Com.Selection.(remove_file ~area_id ~subdirs:subdirs file acc)
                | None ->
                  acc
            ) selection (Msg_from_srv.Selection_processed.get_paths_ok result)
          in
          { m with area_content; selection }
        )
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:(T._t prefs Unable_to_delete_selection);
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
  | Action_other.Selection.Download_start -> (
      match Com.Selection.get_area_content m.selection with
      | None ->
        return m
      | Some area_content ->
        let area_id = Com.Area_content.get_area area_content |> Com.Area.get_id in
        let subdirs = Com.Area_content.get_subdirs area_content in
        let dirnames = Com.Area_content.get_directories area_content |> List.map Com.Directory.get_name in
        let filenames = Com.Area_content.get_files area_content |> List.map Com.File.get_name in
        let c = Js_toast.append_from_list ~l:[""] ~prefix_id:area_id ~fun_msg:(fun _ -> (T._t prefs Download_selection))
            ~fun_cmd:(fun toast_id _ -> Api.send (Action.Selection (Action_other.Selection.Download_do { toast_id; area_id; subdirs; dirnames; filenames })))
        in
        return m ~c
    )
  | Action_other.Selection.Download_do { toast_id; area_id; subdirs; dirnames; filenames } ->
    let payload = Msg_to_srv.Selection.make ~area_id ~subdirs ~dirnames ~filenames
                  |> Msg_to_srv.Selection.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Download_selection) in
    let c = [Api.http_post_response_blob ~url ~payload (fun status data -> Action.Selection (Action_other.Selection.Download_done { toast_id; status; data }))] in
    return m ~c
  | Action_other.Selection.Download_done { toast_id; status; data } ->
    let m =
      match status with
      | 200 -> (
          (* https://www.alexhadik.com/writing/xhr-file-download/ *)
          let blob = Js_of_ocaml.File.blob_from_string ~contentType:"application/zip" (Ojs.string_of_js data) in
          let url = Js_of_ocaml.Dom_html.window##._URL##createObjectURL(blob) in
          let a = Dom_html.(createA document) in
          a##.style##.display := Js.string "none";
          Dom.appendChild Dom_html.window##.document##.body a;
          a##.href := url;
          a##click;
          Js_of_ocaml.Dom_html.window##._URL##revokeObjectURL(url);
          m
        )
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:(T._t prefs Unable_to_download_selection);
        Js_toast.show ~document ~toast_id;
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
  | Action_other.Selection.Copy_move_ask action -> (
      let target_area_id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
      let target_subdirs = Com.Area_content.get_subdirs m.Model.area_content in
      match Com.Selection.get_area_content m.selection with
      | None ->
        return m
      | Some area_content ->
        let area_id = Com.Area_content.get_area area_content |> Com.Area.get_id in
        let subdirs = Com.Area_content.get_subdirs area_content in
        let dirnames = Com.Area_content.get_directories area_content |> List.map Com.Directory.get_name in
        let filenames = Com.Area_content.get_files area_content |> List.map Com.File.get_name in
        let title = Com.Path.(match action with Copy -> (T._t prefs Copy_selection) | Move -> (T._t prefs Move_selection)) in
        let txt_bt_ok = Com.Path.(match action with Copy -> (T._t prefs Copy) | Move -> (T._t prefs Move)) in
        let modal = Modal.set_selection_cut_copy m.modal
                    |> Modal.enable_bt_ok
                    |> Modal.set_title title
                    |> Modal.set_input_content ""
                    |> Modal.set_txt_bt_ok txt_bt_ok
                    |> Modal.set_txt_bt_cancel (T._t prefs Cancel)
                    |> Modal.set_fun_bt_ok (fun _ -> Action.Selection (Action_other.Selection.Copy_move_start { action; area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs }))
        in
        let m = { m with modal } in
        let () = Js_modal.show () in
        return m
    )
  | Action_other.Selection.Copy_move_start { action; area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs } ->
    let paste_mode = Modal.get_paste_mode m.modal in
    let msg = Com.Path.(match action with Copy -> (T._t prefs Copy_selection) | Move -> (T._t prefs Move_selection)) in
    let c = Js_toast.append_from_list ~l:[""] ~prefix_id:area_id ~fun_msg:(fun _ -> msg)
        ~fun_cmd:(fun toast_id _ -> Api.send (Action.Selection (Action_other.Selection.Copy_move_do { action; toast_id; area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs; paste_mode })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.Selection.Copy_move_do { action; toast_id; area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs; paste_mode } ->
    let () = Js_toast.show ~document ~toast_id in
    let selection = Msg_to_srv.Selection.make ~area_id ~subdirs ~dirnames ~filenames in
    let payload = Msg_to_srv.Selection_paste.make ~action ~selection ~paste_mode ~target_area_id ~target_subdirs
                  |> Msg_to_srv.Selection_paste.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Copy_selection) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.Selection (Action_other.Selection.Copy_move_done { action; toast_id; target_area_id; target_subdirs; status; json }))] in
    return m ~c
  | Action_other.Selection.Copy_move_done { action; toast_id; target_area_id; target_subdirs; status; json } ->
    let m =
      match status with
      | 200 -> (
          let result = Yojson.Safe.from_string json |> Msg_from_srv.Selection_paste_processed.t_of_yojson in
          let msg = Com.Path.(match action with Copy -> (T._t prefs Selection_copied) | Move -> (T._t prefs Selection_moved)) in
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg;
          let area_content = List.fold_left (
              fun acc e ->
                let e = Msg_from_srv.Selection_paste_processed.get_directory_ok_to_dir e in
                Com.Area_content.(add_new_directory ~id:target_area_id ~subdirs:target_subdirs ~directory:e acc)
            ) m.area_content (Msg_from_srv.Selection_paste_processed.get_directories_ok result)
          in
          let area_content = List.fold_left (
              fun acc e ->
                let path = Msg_from_srv.Selection_paste_processed.get_file_ok_to_file e in
                Com.Area_content.(add_new_path ~id:target_area_id ~subdirs:target_subdirs ~path acc)
            ) area_content (Msg_from_srv.Selection_paste_processed.get_paths_ok result)
          in
          { m with area_content }
        )
      | _ ->
        let msg =
          match json with
          | "" -> Com.Path.(match action with Copy -> (T._t prefs Unable_to_copy_selection) | Move -> (T._t prefs Unable_to_move_selection))
          | _ -> json
        in
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg;
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m