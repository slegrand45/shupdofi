module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
module Com = Shupdofi_com
module Html = Shupdofi_clt_html.Html
module Icon = Shupdofi_clt_icon.Icon
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing
module Selection = Shupdofi_com.Selection
module User = Shupdofi_com.User

open Vdom

let view m content =
  let area = Com.Area_content.get_area m.Model.area_content in
  let subdirs = Com.Area_content.get_subdirs m.Model.area_content in
  let user_name = User.get_name m.Model.user in
  let selection_count = Selection.count m.selection in
  let same_location = List.exists (Com.Selection.same_location ~area ~subdirs) m.selection in
  let visibility_badge = if (selection_count > 0) then "visible" else "invisible" in
  let menu_disabled_clear_delete = if (selection_count > 0) then "" else "disabled" in
  let menu_disabled_paste = if (selection_count > 0 && not same_location) then "" else "disabled" in
  let menu_aria_disabled = if (selection_count > 0) then [] else [attr "aria-disabled" "true"] in
  let div_account =
    match user_name with
    | "" -> []
    | _ -> [
        div ~a:[class_ "col-auto"] [
          elt "form" ~a:[str_prop "role" "link"] [
            div ~a:[class_ "dropdown"] [
              elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm position-relative dropdown-toggle";
                               attr "data-bs-toggle" "dropdown"; attr "aria-expanded" "false";] [
                Icon.shopping_basket ~label:"Selection" ~aria_id:("selection-icon-shopping-basket") ~class_attr:"fs-6";
                elt "span" ~a:[class_ ("position-absolute top-0 start-100 translate-middle badge rounded-pill bg-primary " ^ visibility_badge)] [
                  text (selection_count |> string_of_int)
                ];
                elt "span" ~a:[class_ "visually-hidden"] [
                  text "Selection"
                ]
              ];
              elt "ul" ~a:[class_ "dropdown-menu"] [
                elt "li" [
                  elt "a" ~a:([class_ ("dropdown-item py-2 my-2 " ^ menu_disabled_paste); str_prop "href" "#"] @ menu_aria_disabled) [
                    Icon.content_copy ~class_attr:"fs-6" ~label:"Copy & paste"
                      ~aria_id:("shopping-basket-icon-content-copy");
                    elt "span" ~a:[class_ "ms-1 fs-6"] [ text "Copy & paste" ]
                  ]
                ];
                elt "li" [
                  elt "a" ~a:([class_ ("dropdown-item py-2 my-2 " ^ menu_disabled_paste); str_prop "href" "#"] @ menu_aria_disabled) [
                    Icon.content_cut ~class_attr:"fs-6" ~label:"Cut & paste"
                      ~aria_id:("shopping-basket-icon-content-cut");
                    elt "span" ~a:[class_ "ms-1 fs-6"] [ text "Cut & paste" ]
                  ]
                ];
                elt "li" [
                  elt "a" ~a:([class_ ("dropdown-item py-2 my-2 " ^ menu_disabled_clear_delete); str_prop "href" "#";
                               onclick_cancel (fun _ -> Some (Action.Selection (Action_other.Selection.Clear { area; subdirs })))]
                              @ menu_aria_disabled) [
                    Icon.clear ~class_attr:"fs-6" ~label:"Clear"
                      ~aria_id:("shopping-basket-icon-clear");
                    elt "span" ~a:[class_ "ms-1 fs-6"] [ text "Clear" ]
                  ]
                ];
                elt "li" [
                  elt "hr" ~a:[class_ "dropdown-divider"] []
                ];
                elt "li" [
                  elt "a" ~a:([class_ ("dropdown-item py-2 my-2 " ^ menu_disabled_clear_delete); str_prop "href" "#"] @ menu_aria_disabled) [
                    Icon.delete_forever ~class_attr:"fs-6" ~label:"Delete"
                      ~aria_id:("shopping-basket-icon-delete-forever");
                    elt "span" ~a:[class_ "ms-1 fs-6"] [ text "Delete" ]
                  ]
                ]
              ]
            ]
          ]
        ];
        div ~a:[class_ "col-auto m-auto"] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.account_circle ~class_attr:"fs-6";
            elt "span" ~a:[class_ "ms-1"] [ text user_name ]
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