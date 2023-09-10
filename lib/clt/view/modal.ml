module Action = Shupdofi_clt_model.Action
module Icon = Shupdofi_clt_icon.Icon
module Modal = Shupdofi_clt_model.Modal
module Model = Shupdofi_clt_model.Model

open Vdom

let body m =
  let modal = m.Model.modal in
  match (Modal.is_new_entry modal) with
  | true -> 
    elt "form" [
      div ~a:[class_ "my-3"] [
        elt "input" ~a:[class_ "form-control"; attr "aria-label" "New entry";
                        value (Modal.get_input_content modal); oninput (fun e -> Action.Modal_set_input_content { content = e })] []
      ]
    ]
  | false ->
    let switch_checked = (if (Modal.get_input_switch modal) then bool_prop "checked" true else bool_prop "checked" false) in
    match (Modal.is_confirm_delete modal) with
    | true ->
      elt "form" [
        div ~a:[class_ "my-3 text-danger fs-1 d-flex justify-content-center"] [
          Icon.warning_amber ~class_attr:"icon"
        ];
        div ~a:[class_ "my-3"] [
          div ~a:[class_ "form-check form-switch"] [
            elt "input" ~a:[class_ "form-check-input"; type_ "checkbox"; attr "role" "switch"; attr "id" "formConfirmDeleteSwitch";
                            switch_checked; onclick (fun _ -> Action.Modal_toggle_switch)] [];
            elt "label" ~a:[class_ "form-check-label"; attr "for" "formConfirmDeleteSwitch"] [
              text (Modal.get_txt_switch modal)
            ]
          ]
        ]
      ]
    | false ->
      match (Modal.is_selection_cut_copy modal) with
      | true ->
        elt "form" [
          div ~a:[class_ "my-3"] [
            div ~a:[class_ "form-check form-switch"] [
              elt "input" ~a:[class_ "form-check-input"; type_ "checkbox"; attr "role" "switch"; attr "id" "formAskReplaceSelectionCutCopy";
                              switch_checked; onclick (fun _ -> Action.Modal_toggle_switch)] [];
              elt "label" ~a:[class_ "form-check-label"; attr "for" "formAskReplaceSelectionCutCopy"] [
                text (Modal.get_txt_switch modal)
              ]
            ]
          ]
        ]
      | false ->
        div []

let view m =
  let modal = m.Model.modal in
  let body = body m in
  let fun_ok = Modal.get_fun_bt_ok modal in
  let attr_disabled_bt_ok =
    match Modal.bt_ok_is_disabled modal with
    | true -> str_prop "disabled" "disabled"
    | false -> str_prop "" ""
  in
  div ~a:[class_ "modal"; str_prop "tabindex" "-1"; str_prop "id" "modal-container"] [
    div ~a:[class_ "modal-dialog"] [
      div ~a:[class_ "modal-content"] [
        div ~a:[class_ "modal-header"] [
          elt "h5" ~a:[class_ "modal-title"; str_prop "id" "modal-title"] [
            text (Modal.get_title modal)
          ];
          elt "button" ~a:[class_ "btn-close"; type_ "button"; attr "data-bs-dismiss" "modal"; attr "aria-label" "Close";
                           onclick (fun _ -> Action.Modal_close)] [];
        ];
        div ~a:[class_ "modal-body"; str_prop "id" "modal-body"] [
          body
        ];
        div ~a:[class_ "modal-footer"] [
          elt "button" ~a:[class_ "btn btn-secondary"; type_ "button"; attr "data-bs-dismiss" "modal";
                           str_prop "id" "modal-btn-cancel"; onclick (fun _ -> Action.Modal_cancel)] [
            text (Modal.get_txt_bt_cancel modal)
          ];
          elt "button" ~a:[class_ "btn btn-primary"; type_ "button"; str_prop "id" "modal-btn-ok";
                           attr_disabled_bt_ok; onclick fun_ok] [
            text (Modal.get_txt_bt_ok modal)
          ];
        ];
      ]
    ]
  ];