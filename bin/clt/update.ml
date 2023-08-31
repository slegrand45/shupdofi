module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
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
module Selection = Com.Selection
module Sorting = Com.Sorting
module Update_other = Shupdofi_clt_update

open Vdom
open Js_browser

let update m a =
  match a with
  | Action.Nothing ->
    return m
  | Action.Set_current_url { url } ->
    let () = Js_browser.(History.push_state (Window.history window) (Ojs.string_to_js "") "" url) in
    return m ~c:[Api.send Action.Current_url_modified]
  | Action.Current_url_modified -> (
      let req_user = Api.send (Action.User Action_other.User.Do) in
      let route = Routing.Router.from_pathname (Location.pathname (Window.location window)) in
      let m = Model.set_route route m in
      (* fetch de tous les blocs de la page *)
      match route with
      | Home
      | Areas ->
        return m ~c:[Api.send (Action.Fetch_start { block = Block.Fetchable.areas }); req_user]
      | Area_content (id, subdirs) ->
        return m ~c:[Api.send (Action.Fetch_start { block = (Block.Fetchable.area_content id subdirs) }); req_user]
    )
  | Action.Fetch_start { block } ->
    let m = { m with block = Block.Fetchable.to_loading block } in
    return m ~c:[Api.send (Action.Fetch { block })]
  | Action.Fetch { block } ->
    return m ~c:[Api.http_get ~url:(Routing.Api.(to_url (Block.Fetchable.route_api block))) ~payload:"" (fun status json -> Action.Fetched { block; status; json })]
  | Action.Fetched { block; status; json } -> (
      let m = { m with block = Block.Fetchable.to_loaded block } in
      match status with
      | 200 ->
        let m =
          match Block.Fetchable.get_id block with
          | Block.Fetchable.Areas ->
            { m with areas = Yojson.Safe.from_string json |> Com.Area.collection_of_yojson }
          | Block.Fetchable.Area_content _ ->
            { m with area_content = Yojson.Safe.from_string json |> Com.Area_content.t_of_yojson }
          | _ -> m
        in
        return m
      | _ ->
        return m
    )
  | Action.Area_go_to_subdir { name } ->
    let id = Com.Area_content.get_area m.Model.area_content |> Com.Area.get_id in
    let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
    let new_subdirs = subdirs @ [name] in
    let route = Routing.Page.Area_content (id, new_subdirs) in
    let url = Routing.Page.to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) route in
    return { m with area_content = (Com.Area_content.set_subdirs new_subdirs m.Model.area_content) }
      ~c:[Api.send (Action.Set_current_url { url })]
  | Action.Upload_file a -> Update_other.Upload_file.update m a
  | Action.New_directory a -> Update_other.New_directory.update m a
  | Action.Rename_directory a -> Update_other.Rename_directory.update m a
  | Action.Delete_directory a -> Update_other.Delete_directory.update m a
  | Action.Rename_file a -> Update_other.Rename_file.update m a
  | Action.Delete_file a -> Update_other.Delete_file.update m a
  | Action.User a -> Update_other.User.update m a
  | Action.Selection a -> Update_other.Selection.update m a
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
  | Action.Click_sorting click_criteria ->
    let sorting = m.sorting in
    let criteria = Sorting.get_criteria sorting in
    let direction = Sorting.get_direction sorting in
    let new_sorting =
      match click_criteria with
      | _ when criteria = click_criteria -> Sorting.make ~criteria ~direction:(Sorting.Direction.alternate direction)
      | _ -> Sorting.make ~criteria:click_criteria ~direction:(Sorting.Direction.ascending)
    in
    return { m with sorting = new_sorting }
  | Action.Click_select_file { area; subdirs; file } ->
    let selection = Com.Selection.add_file ~area ~subdirs file m.selection in
    return { m with selection }
  | Action.Click_select_directory { area; subdirs; directory } ->
    let selection = Com.Selection.add_directory ~area ~subdirs directory m.selection in
    return { m with selection }
  | Action.Click_select_all { area; subdirs; directories; files } ->
    let selection = Com.Selection.all ~area ~subdirs ~directories ~files m.selection in
    return { m with selection }
