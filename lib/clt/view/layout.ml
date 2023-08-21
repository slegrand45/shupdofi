module Html = Shupdofi_clt_html.Html
module Icon = Shupdofi_clt_icon.Icon
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing
module User = Shupdofi_com.User

open Vdom

let view m content =
  let user_name = User.get_name m.Model.user in
  let div_account =
    match user_name with
    | "" -> []
    | _ -> [
        div ~a:[class_ "col-auto"] [
          elt "form" ~a:[str_prop "role" "link"] [
            elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm position-relative"] [
              div ~a:[class_ "d-flex align-items-center justify-content-around"] [
                Icon.shopping_basket ~label:"Selection" ~aria_id:("selection-icon-shopping-basket") ~class_attr:"fs-6";
                elt "span" ~a:[class_ "position-absolute top-0 start-100 translate-middle badge rounded-pill bg-primary"] [
                  text "99+"
                ];
                elt "span" ~a:[class_ "visually-hidden"] [
                  text "Selection"
                ]
              ]
            ]
          ]
        ];
        div ~a:[class_ "col-auto"] [
          elt "form" ~a:[str_prop "role" "link"] [
            elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm"] [
              div ~a:[class_ "d-flex align-items-center justify-content-around"] [
                Icon.account_circle ~class_attr:"fs-6";
                elt "span" ~a:[class_ "ms-1"] [ text user_name ]
              ]
            ]
          ]
        ]
      ]
  in
  div ~a:[class_ "container-fluid d-flex flex-column min-vh-100"] [
    elt "header" ~a:[class_ "border-bottom border-info-subtle mb-4 bg-light"] [
      elt "nav" ~a:[class_ "navbar"] [
        div ~a:[class_ "container-fluid"] [
          Html.link Routing.Page.Home ~class_attr:"navbar-brand d-flex" ~title:"Home" [
            Icon.home ~class_attr:"fs-6"
          ];
          div ~a:[class_ "row justify-content-end"] div_account
        ]          
      ]
    ];
    content;
    elt "footer" ~a:[class_ "mt-auto border-top border-info-subtle bg-light"] [
      div ~a:[class_ "row justify-content-center align-items-center pt-2 pb-2"] [
        div ~a:[class_ "col"] [
          elt "a" ~a:[str_prop "href" "https://www.../"; str_prop "target" "_blank"] [
            elt "small" [
              text "SH.UP.DO.FI v1.1"
            ]
          ]
        ]
      ]
    ];
    Modal.view m;
  ]