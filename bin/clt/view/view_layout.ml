open Vdom

let view m content =
  div ~a:[class_ "container-fluid d-flex flex-column min-vh-100"] [
    elt "header" ~a:[class_ "border-bottom border-info-subtle mb-4"] [
      elt "nav" ~a:[class_ "navbar"] [
        div ~a:[class_ "container-fluid"] [
          Html.link Shupdofi_clt.Route_page.Home ~class_attr:"navbar-brand d-flex" ~title:"Home" [
            Icon.house ~class_attr:"fs-6"
          ];
          div ~a:[class_ "row justify-content-end"] [
            div ~a:[class_ "col-auto"] [
              elt "form" ~a:[str_prop "role" "link"] [
                elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm"] [
                  div ~a:[class_ "d-flex align-items-center justify-content-around"] [
                    Icon.gear ~class_attr:"fs-6";
                    elt "span" ~a:[class_ "ms-1"] [ text " Admin " ]
                  ]
                ]
              ]
            ];
            div ~a:[class_ "col-auto"] [
              elt "form" ~a:[str_prop "role" "link"] [
                elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm"] [
                  div ~a:[class_ "d-flex align-items-center justify-content-around"] [
                    Icon.person_circle ~class_attr:"fs-6";
                    elt "span" ~a:[class_ "ms-1"] [ text " Stéph. Legrand " ]
                  ]
                ]
              ]
            ]
          ]
        ]          
      ]
    ];
    content;
    elt "footer" ~a:[class_ "mt-auto border-top border-info-subtle"] [          
      div ~a:[class_ "row justify-content-center align-items-center pt-2 pb-2"] [
        div ~a:[class_ "col"] [
          elt "small" [
            text "SH.UP.DO.FI v1.1"
          ]
        ]
      ]
    ];
    View_modal.view();
  ]