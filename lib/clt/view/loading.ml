open Vdom

let view () =
  div ~a:[class_ "d-flex justify-content-center align-items-center"] [
    div ~a:[class_ "spinner-border text-primary"; style "width" "5rem"; style "height" "5rem"; str_prop "role" "status"; attr "aria-hidden" "true"] [
      elt "span" ~a:[class_ "visually-hidden"] [ text "Loading..." ]
    ]
  ]
