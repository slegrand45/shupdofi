module Action = Shupdofi_clt_model.Action
module Modal = Shupdofi_clt_model.Modal
module Model = Shupdofi_clt_model.Model

open Vdom

let view m =
  let modal = m.Model.modal in
  let fun_ok = Modal.get_fun_bt_ok modal in
  div ~a:[class_ "modal"; str_prop "tabindex" "-1"; str_prop "id" "modal-container"] [
    div ~a:[class_ "modal-dialog"] [
      div ~a:[class_ "modal-content"] [
        div ~a:[class_ "modal-header"] [
          elt "h5" ~a:[class_ "modal-title"; str_prop "id" "modal-title"] [
            text (Modal.get_title modal)
          ];
          elt "button" ~a:[class_ "btn-close"; type_ "button"; attr "data-bs-dismiss" "modal"; attr "aria-label" "Close";
                           onclick (fun e -> Action.Modal_close)] [];
        ];
        div ~a:[class_ "modal-body"; str_prop "id" "modal-body"] [
          elt "form" [
            div ~a:[class_ "my-3"] [
              elt "input" ~a:[class_ "form-control"; attr "aria-label" "Input field";
                              value (Modal.get_input_content modal); oninput (fun e -> Action.Modal_set_input_content e)] []
            ]
          ]
        ];
        div ~a:[class_ "modal-footer"] [
          elt "button" ~a:[class_ "btn btn-secondary"; type_ "button"; attr "data-bs-dismiss" "modal";
                           str_prop "id" "modal-btn-cancel"; onclick (fun e -> Action.Modal_cancel)] [
            text (Modal.get_txt_bt_cancel modal)
          ];
          elt "button" ~a:[class_ "btn btn-primary"; type_ "button"; str_prop "id" "modal-btn-ok";
                           onclick fun_ok] [
            text (Modal.get_txt_bt_ok modal)
          ];
        ];
      ]
    ]
  ];