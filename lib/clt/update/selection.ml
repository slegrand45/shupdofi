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
        let msg = Printf.sprintf "I understand that all the selected directories and files will be permanently deleted." in
        let modal = Modal.set_confirm_delete msg m.modal
                    |> Modal.set_input_switch false
                    |> Modal.disable_bt_ok
                    |> Modal.set_title "Delete selection"
                    |> Modal.set_input_content ""
                    |> Modal.set_txt_bt_ok "Delete"
                    |> Modal.set_txt_bt_cancel "Cancel"
                    |> Modal.set_fun_bt_ok (fun _ -> Action.Selection (Action_other.Selection.Delete_start { area_id; subdirs; dirnames; filenames }))
        in
        let m = { m with modal } in
        let () = Js_modal.show () in
        return m
    )
  | Action_other.Selection.Delete_start { area_id; subdirs; dirnames; filenames } ->
    let c = Js_toast.append_from_list ~l:[""] ~prefix_id:area_id ~fun_msg:(fun _ -> "Delete selection")
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
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:("Selection deleted");
          let area_content = List.fold_left (
              fun acc e -> Com.Area_content.(remove_directory ~id:area_id ~subdirs:subdirs ~dirname:(Com.Directory.get_name e) acc)
            ) m.area_content (Msg_from_srv.Selection_processed.get_directories_ok result)
          in
          let selection = List.fold_left (
              fun acc e -> Com.Selection.(remove_directory ~area_id ~subdirs:subdirs e acc)
            ) m.selection (Msg_from_srv.Selection_processed.get_directories_ok result)
          in
          let area_content = List.fold_left (
              fun acc e ->
                match (Com.Path.get_file e) with
                | Some file ->
                  Com.Area_content.(remove_file ~id:area_id ~subdirs:subdirs ~filename:(Com.File.get_name file) acc)
                | None ->
                  acc
            ) area_content (Msg_from_srv.Selection_processed.get_paths_ok result)
          in
          let selection = List.fold_left (
              fun acc e ->
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
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to delete selection");
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
        let c = Js_toast.append_from_list ~l:[""] ~prefix_id:area_id ~fun_msg:(fun _ -> "Download selection")
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
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to delete selection");
        Js_toast.show ~document ~toast_id;
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m
  | Action_other.Selection.Copy_ask -> (
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
        let msg = Printf.sprintf "Overwrite existing files (otherwise the file will be silently ignored)." in
        let modal = Modal.set_selection_cut_copy msg m.modal
                    |> Modal.set_input_switch false
                    |> Modal.enable_bt_ok
                    |> Modal.set_title "Copy selection"
                    |> Modal.set_input_content ""
                    |> Modal.set_txt_bt_ok "Copy"
                    |> Modal.set_txt_bt_cancel "Cancel"
                    |> Modal.set_fun_bt_ok (fun _ -> Action.Selection (Action_other.Selection.Copy_start { area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs }))
        in
        let m = { m with modal } in
        let () = Js_modal.show () in
        return m
    )
  | Action_other.Selection.Copy_start { area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs } ->
    let overwrite = Modal.get_input_switch m.modal in
    let c = Js_toast.append_from_list ~l:[""] ~prefix_id:area_id ~fun_msg:(fun _ -> "Copy selection")
        ~fun_cmd:(fun toast_id _ -> Api.send (Action.Selection (Action_other.Selection.Copy_do { toast_id; area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs; overwrite })))
    in
    let c = Api.send(Action.Modal_close) :: c in
    return m ~c
  | Action_other.Selection.Copy_do { toast_id; area_id; subdirs; dirnames; filenames; target_area_id; target_subdirs; overwrite } ->
    let () = Js_toast.show ~document ~toast_id in
    let selection = Msg_to_srv.Selection.make ~area_id ~subdirs ~dirnames ~filenames in
    let payload = Msg_to_srv.Selection_paste.make ~selection ~overwrite ~target_area_id ~target_subdirs
                  |> Msg_to_srv.Selection_paste.yojson_of_t |> Yojson.Safe.to_string
    in
    let url = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) Copy_selection) in
    let c = [Api.http_post ~url ~payload (fun status json -> Action.Selection (Action_other.Selection.Copy_done { toast_id; target_area_id; target_subdirs; status; json }))] in
    return m ~c
  | Action_other.Selection.Copy_done { toast_id; target_area_id; target_subdirs; status; json } ->
    let m =
      match status with
      | 200 -> (
          let result = Yojson.Safe.from_string json |> Msg_from_srv.Selection_paste_processed.t_of_yojson in
          let selection = Msg_from_srv.Selection_paste_processed.get_selection result in
          Js_toast.set_status_ok ~doc:Dom_html.document ~id:toast_id ~delay:5.0 ~msg:("Selection copied");
          let area_content = List.fold_left (
              fun acc e -> Com.Area_content.(add_new_directory ~id:target_area_id ~subdirs:target_subdirs ~directory:e acc)
            ) m.area_content (Msg_from_srv.Selection_processed.get_directories_ok selection)
          in
          let area_content = List.fold_left (
              fun acc e ->
                let file = Com.Path.get_file e |> Option.get in
                Com.Area_content.(add_new_file ~id:target_area_id ~subdirs:target_subdirs ~file acc)
            ) area_content (Msg_from_srv.Selection_processed.get_paths_ok selection)
          in
          { m with area_content }
        )
      | _ ->
        Js_toast.set_status_ko ~doc:Dom_html.document ~id:toast_id ~msg:("Unable to copy selection");
        m
    in
    let () = Js_toast.clean_hiddens ~document in
    return m