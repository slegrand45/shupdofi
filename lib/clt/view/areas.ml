module Block = Shupdofi_clt_model.Block
module Com = Shupdofi_com
module Html = Shupdofi_clt_html.Html
module Icon = Shupdofi_clt_icon.Icon
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing

(* open Js_browser *)
open Vdom

let area v =
  div ~a:[class_ "col"] [
    div ~a:[class_ "card h-100"] [
      div ~a:[class_ "card-body"] [
        elt "h5" ~a:[class_ "card-title text-center"] [
          text (Com.Area.get_name v)
        ];
        elt "p" ~a:[class_ "card-text"] [
          text (Com.Area.get_description v)
        ]
      ];
      div ~a:[class_ "card-footer text-end"] [
        elt "small" ~a:[class_ "text-body-secondary"] [
          Html.link Routing.Page.(Area_content ((Com.Area.get_id v), [])) ~class_attr:""
            ~title:("Go to area " ^ (Com.Area.get_name v)) [
            Icon.box_arrow_right ~class_attr:"fs-5"
          ]
        ];
      ]
    ]
  ]

let view m =
  if (Block.Fetchable.is_loaded m.Model.block) then
    let areas = List.fold_left (fun acc e -> acc @ [area e]) [] m.Model.areas in
    elt "content" [
      div ~a:[class_ "row row-cols-1 row-cols-md-3 row-cols-lg-4 g-4"] areas
    ]
  else
    elt "content" [
      Loading.view ()
    ]


    (*
    div ~a:[class_ "row row-cols-1 row-cols-md-3 row-cols-lg-4 gy-5 align-items-center"] [
      div ~a:[class_ "col text-center"] [
        elt "button" ~a:[class_ "btn btn-lg btn-light"; str_prop "type" "button";] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.files ~class_attr:"";
            elt "span" ~a:[class_ "ms-2"] [ text " Area XXX " ]
          ]
        ];
      ];
      div ~a:[class_ "col text-center"] [
        elt "button" ~a:[class_ "btn btn-lg btn-light"; str_prop "type" "button";] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.files ~class_attr:"";
            elt "span" ~a:[class_ "ms-2"] [ text " Area XXX " ]
          ]
        ];
      ];
      div ~a:[class_ "col text-center"] [
        elt "button" ~a:[class_ "btn btn-lg btn-light"; str_prop "type" "button";] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.files ~class_attr:"";
            elt "span" ~a:[class_ "ms-2"] [ text " Area XXX Area XXX Area XXX Area XXX " ]
          ]
        ];
      ];


      div ~a:[class_ "col text-center"] [
        div ~a:[class_ "btn-group btn-group-lg d-flex justify-content-around w-100";] [
          elt "button" ~a:[class_ "btn btn-light"; str_prop "type" "button";] [
            Icon.files ~class_attr:"";
          ];
          elt "button" ~a:[class_ "btn"; str_prop "type" "button";] [
            elt "span" [ text " Area XXX Area BTN GROUP XXX Area XXX Area XXX " ]
          ];
        ]
      ];
      div ~a:[class_ "col text-center"] [
        div ~a:[class_ "btn-group btn-group-lg d-flex justify-content-around w-100";] [
          elt "button" ~a:[class_ "btn btn-light"; str_prop "type" "button";] [
            Icon.files ~class_attr:"";
          ];
          elt "button" ~a:[class_ "btn"; str_prop "type" "button";] [
            elt "span" [ text " Area XXX BTN GROUP " ]
          ];
        ]
      ];


      div ~a:[class_ "col text-center"] [
        elt "button" ~a:[class_ "btn btn-lg btn-light"; str_prop "type" "button";] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.files ~class_attr:"";
            elt "span" ~a:[class_ "ms-2"] [ text " Area XXX " ]
          ]
        ];
      ];
      div ~a:[class_ "col text-center"] [
        elt "button" ~a:[class_ "btn btn-lg btn-light"; str_prop "type" "button";] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.files ~class_attr:"";
            elt "span" ~a:[class_ "ms-2"] [ text " Area XXX " ]
          ]
        ];
      ];
      div ~a:[class_ "col text-center"] [
        elt "button" ~a:[class_ "btn btn-lg btn-light"; str_prop "type" "button";] [
          div ~a:[class_ "d-flex align-items-center justify-content-around"] [
            Icon.files  ~class_attr:"";
            elt "span" ~a:[class_ "ms-2"] [ text " Area XXX " ]
          ]
        ];
      ]
    ];



    div ~a:[class_ "d-grid gap-2 "] [

      div ~a:[class_ "btn-group btn-group-lg d-flex justify-content-around";] [
        elt "button" ~a:[class_ "btn btn-light"; str_prop "type" "button";] [
          Icon.files ~class_attr:"";
        ];
        elt "button" ~a:[class_ "btn"; str_prop "type" "button";] [
          elt "span" [ text " Area XXX Area BTN GROUP XXX Area XXX Area XXX " ]
        ];
      ];
      div ~a:[class_ "btn-group btn-group-lg d-flex justify-content-around";] [
        elt "button" ~a:[class_ "btn btn-light"; str_prop "type" "button";] [
          Icon.files ~class_attr:"";
        ];
        elt "button" ~a:[class_ "btn"; str_prop "type" "button";] [
          elt "span" [ text " Area XXX BTN GROUP " ]
        ];
      ];

    ]
    *)
