module Action = Shupdofi_clt_model.Action
module Block = Shupdofi_clt_model.Block
module Com = Shupdofi_com
module Html = Shupdofi_clt_html.Html
module Icon = Shupdofi_clt_icon.Icon
module Intl = Shupdofi_clt_i18n.Intl
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing

(* open Js_browser *)
open Vdom

let one_line_size_bytes v =
  Option.fold ~none:"" ~some:Int64.to_string (Com.File.get_size_bytes v)

let one_line_mdatetime v =
  let user_language = Intl.user_language () in
  match v with
  | None -> ""
  | Some v -> Intl.fmt_date_hm user_language v

let one_line_directory acc v =
  match Com.Directory.get_name v with
  | "" -> acc
  | name -> 
    elt "tr" ~a:[ondblclick_cancel (fun _ -> Some (Action.Area_go_to_subdir name))] [
      elt "td" [ Icon.folder ~class_attr:"" ];
      elt "td" [ text name ];
      elt "td" [ text (one_line_mdatetime (Com.Directory.get_mdatetime v)) ];
      elt "td" [ text "" ];
    ] :: acc

let one_line_file acc v =
  match Com.File.get_name v with
  | "" -> acc
  | name -> 
    elt "tr" [
      elt "td" [ text "" ];
      elt "td" [ text name ];
      elt "td" [ text (one_line_mdatetime (Com.File.get_mdatetime v)) ];
      elt "td" [ text (one_line_size_bytes v) ];
    ] :: acc

let lines directories files =
  match directories, files with
  | [], [] -> [elt "p"
                 [ text "Empty directory" ]
              ]
  | directories, files ->
    let directories = List.sort (fun e1 e2 -> String.compare (Com.Directory.get_name e1) (Com.Directory.get_name e2)) directories in
    let files = List.sort (fun e1 e2 -> String.compare (Com.File.get_name e1) (Com.File.get_name e2)) files in
    let trs_directories = List.fold_left one_line_directory [] directories |> List.rev in
    let trs_files = List.fold_left one_line_file [] files |> List.rev in
    [div ~a:[class_ "table-responsive"] [
        elt "table" ~a:[class_ "table table-hover"] [
          elt "thead" [
            elt "tr" [
              elt "th" ~a:[str_prop "scope" "col"; str_prop "style" "width: 1em;"] [ text "" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "Name" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "Last modified" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "Size" ];
            ]
          ];
          elt "tbody" (trs_directories @ trs_files)
        ]
      ]]

let breadcrumb_last id e =
  elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
    div ~a:[class_ "dropdown"] [
      elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm btn-light dropdown-toggle";
                       attr "data-bs-toggle" "dropdown"; attr "aria-expanded" "false"] [
        text e
      ];
      elt "ul" ~a:[class_ "dropdown-menu"] [
        elt "li" [
          elt "a" ~a:[class_ "dropdown-item"; str_prop "href" ""; onclick_cancel (fun e -> Some Action.New_directory_ask_dirname)] [
            text "New directory"
          ]
        ];
      ]
    ]
  ]

let breadcrumb_area id with_menu =
  match with_menu with
  | false ->
    elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
      Html.link (Routing.Page.Area_content (id, []))
        ~class_attr:"btn btn-sm btn-light link-underline-light" ~title:"Area" [
        text "Area"
      ]
    ]
  | true -> breadcrumb_last id "Area"

let breadcrumb id l =
  match l with
  | [] -> [breadcrumb_area id true]
  | l ->
    let without_last = List.rev l |> List.tl |> List.rev in
    let only_last = List.rev l |> List.hd in
    let elts, _ = List.fold_left (fun (elts, dirs) e -> (
          elts @ [
            elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
              Html.link (Routing.Page.Area_content (id, dirs @ [e]))
                ~class_attr:"btn btn-sm btn-light link-underline-light" ~title:e [
                text e
              ]
            ]
          ], dirs @ [e])
      ) ([], []) without_last
    in
    [(breadcrumb_area id false)] @ elts @ [(breadcrumb_last id only_last)]

let view m =
  if (Block.Fetchable.is_loaded m.Model.block) then (
    let content = m.Model.area_content in
    let id = Com.Area_content.get_id content in
    let subdirs = Com.Area_content.get_subdirs content in
    let directories = Com.Area_content.get_directories content in
    let files = Com.Area_content.get_files content in
    let lines = lines directories files in
    elt "content" [
      div ~a:[class_ "row justify-content-end"] [
        div ~a:[class_ "col-auto"] [
          elt "form" ~a:[class_ "d-flex"; str_prop "role" "upload"] [
            div ~a:[class_ "input-group input-group-sm"] [
              div ~a:[class_ "input-group-text"] [ Icon.upload ~class_attr:"" ];
              input ~a:[class_ "form-control form-control-sm"; str_prop "type" "file"; value "";
                        attr "aria-label" "upload"; str_prop "id" "fileupload";
                        oninput (fun e -> Action.Upload_file_start "fileupload")] []
            ]
          ];
        ]
      ];
      div ~a:[class_ "row mt-3 mb-3"] [
        div ~a:[class_ "col"] [
          elt "nav" ~a:[class_ ""; attr "aria-label" "breadcrumb"] [
            elt "ol" ~a:[class_ "breadcrumb mt-2 mb-2 align-items-center"] 
              (breadcrumb id subdirs)
          ]
        ]
      ];
      div ~a:[class_ "row justify-content-center"] [
        div ~a:[class_ "col"] lines
      ]
    ]
  ) else (
    elt "content" [
      Loading.view ()
    ]
  )