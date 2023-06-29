open Vdom

module Clt = Shupdofi_clt

let view m =
  let modal = m.Clt.Model.modal in
  div ~a:[class_ "modal"; str_prop "tabindex" "-1"; str_prop "id" "modal-container"] [
    div ~a:[class_ "modal-dialog"] [
      div ~a:[class_ "modal-content"] [
        div ~a:[class_ "modal-header"] [
          elt "h5" ~a:[class_ "modal-title"; str_prop "id" "modal-title"] [
            text (Clt.Modal.get_title modal)
          ];
          elt "button" ~a:[class_ "btn-close"; type_ "button"; str_prop "data-bs-dismiss" "modal"; str_prop "aria-label" "Close";
                           onclick (fun e -> Action.Modal_close)] [];
        ];
        div ~a:[class_ "modal-body"; str_prop "id" "modal-body"] [
          text (Clt.Modal.get_content modal)
        ];
        div ~a:[class_ "modal-footer"] [
          elt "button" ~a:[class_ "btn btn-secondary"; type_ "button"; str_prop "data-bs-dismiss" "modal";
                           str_prop "id" "modal-btn-cancel"; onclick (fun e -> Action.Modal_cancel)] [
            text (Clt.Modal.get_txt_bt_cancel modal)
          ];
          elt "button" ~a:[class_ "btn btn-primary"; type_ "button"; str_prop "id" "modal-btn-ok";
                           onclick (fun e -> Action.Modal_ok)] [
            text (Clt.Modal.get_txt_bt_ok modal)
          ];
        ];
      ]
    ]
  ];