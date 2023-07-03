module Action = Shupdofi_clt_model.Action
module Routing = Shupdofi_clt_routing

open Vdom

let input_file id finput =
  elt "form" [
    elt "div" [
      elt "label" [
        text "Select file to upload"
      ]
        ~a:[class_ "form-label"; str_prop "for" "selectFile"];
      elt "input" []
        ~a:[class_ "form-control"; attr "aria-describedby" "selectFileHelp"; str_prop "id" id; oninput finput; str_prop "type" "file"];
      elt "div" [text "Select file to upload"]
        ~a:[class_ "form-text"; str_prop "id" "selectFileHelp"]
    ]
      ~a:[class_ "mb-3"]
  ]

let link route ~class_attr ~title children =
  let url = Routing.Page.to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) route in
  let f _ = Some (Action.Set_current_url { url }) in
  elt "a" ~a:[class_ class_attr; str_prop "href" url; str_prop "title" title; onclick_cancel f] children
