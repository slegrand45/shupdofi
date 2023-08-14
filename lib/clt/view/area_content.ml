module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
module Block = Shupdofi_clt_model.Block
module Com = Shupdofi_com
module Html = Shupdofi_clt_html.Html
module Icon = Shupdofi_clt_icon.Icon
module Intl = Shupdofi_clt_i18n.Intl
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing
module Size = Shupdofi_com.Size

open Vdom

let one_line_size_bytes v =
  let bytes = Com.File.get_size_bytes v in
  match bytes with
  | None -> ""
  | Some v -> Size.(to_human (from_int64 v))

let one_line_mdatetime v =
  let user_language = Intl.user_language () in
  match v with
  | None -> ""
  | Some v -> Intl.fmt_date_hm user_language v

let one_line_directory user area_id area_subdirs (acc, i) directory =
  let dirname = Com.Directory.get_name directory in
  let href_download = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Download_directory { area_id; area_subdirs; dirname })) in
  let td_download =
    match Com.User.can_do_action ~area_id ~action:Com.Action.download user, Com.User.can_do_action ~area_id ~action:Com.Action.archive user with
    | true, true -> [
        elt "a" ~a:[str_prop "href" href_download; class_ "action hide"; str_prop "download" ""] [
          Icon.file_download ~label:"Download" ~class_attr:"icon" ~aria_id:("directory-icon-title-file-download" ^ (string_of_int i))
        ];
      ]
    | _, _ -> []
  in
  let td_rename =
    match Com.User.can_do_action ~area_id ~action:Com.Action.rename user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Rename_directory (Action_other.Rename_directory.Ask { directory })))] [
          Icon.edit ~label:"Rename" ~class_attr:"icon" ~aria_id:("directory-icon-title-edit" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  let td_delete =
    match Com.User.can_do_action ~area_id ~action:Com.Action.delete user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Delete_directory (Action_other.Delete_directory.Ask { directory })))] [
          Icon.delete_forever ~label:"Delete" ~class_attr:"icon" ~aria_id:("directory-icon-delete-forever" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  match Com.Directory.get_name directory with
  | "" -> (acc, i + 1)
  | name -> (
      elt "tr" ~a:[class_ "line"] [
        elt "td" [ Icon.folder ~class_attr:"" ];
        elt "td" ~a:[onclick_cancel (fun _ -> Some (Action.Area_go_to_subdir { name }))] [ text name ];
        elt "td" [ text (one_line_mdatetime (Com.Directory.get_mdatetime directory)) ];
        elt "td" [ text "" ];
        elt "td" ~a:[class_ "text-center"] td_download;
        elt "td" ~a:[class_ "text-center"] td_rename;
        elt "td" ~a:[class_ "text-center"] td_delete;
      ] :: acc, i + 1)

let one_line_file user area_id area_subdirs (acc, i) file =
  let filename = Com.File.get_name file in
  let href_download = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Download_file { area_id; area_subdirs; filename })) in
  let td_download =
    match Com.User.can_do_action ~area_id ~action:Com.Action.download user with
    | true -> [
        elt "a" ~a:[str_prop "href" href_download; class_ "action hide"; str_prop "download" ""] [
          Icon.file_download ~label:"Download" ~class_attr:"icon" ~aria_id:("file-icon-title-file-download" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  let td_rename =
    match Com.User.can_do_action ~area_id ~action:Com.Action.rename user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Rename_file (Action_other.Rename_file.Ask { file })))] [
          Icon.edit ~label:"Rename" ~class_attr:"icon" ~aria_id:("file-icon-title-edit" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  let td_delete =
    match Com.User.can_do_action ~area_id ~action:Com.Action.delete user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Delete_file (Action_other.Delete_file.Ask { file })))] [
          Icon.delete_forever ~label:"Delete" ~class_attr:"icon" ~aria_id:("file-icon-delete-forever" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  match Com.File.get_name file with
  | "" -> (acc, i + 1)
  | name -> (
      elt "tr" ~a:[class_ "line"] [
        elt "td" [ text "" ];
        elt "td" [ text name ];
        elt "td" [ text (one_line_mdatetime (Com.File.get_mdatetime file)) ];
        elt "td" [ text (one_line_size_bytes file) ];
        elt "td" ~a:[class_ "text-center"] td_download;
        elt "td" ~a:[class_ "text-center"] td_rename;
        elt "td" ~a:[class_ "text-center"] td_delete;
      ] :: acc, i + 1)

let lines user area_id subdirs directories files =
  match directories, files with
  | [], [] -> [elt "p"
                 [ text "Empty directory" ]
              ]
  | directories, files ->
    let directories = List.sort (fun e1 e2 -> String.compare (Com.Directory.get_name e1) (Com.Directory.get_name e2)) directories in
    let files = List.sort (fun e1 e2 -> String.compare (Com.File.get_name e1) (Com.File.get_name e2)) files in
    let trs_directories = List.fold_left (one_line_directory user area_id subdirs) ([], 1) directories |> fst |> List.rev in
    let trs_files = List.fold_left (one_line_file user area_id subdirs) ([], 1) files |> fst |> List.rev in
    [div ~a:[class_ "table-responsive"] [
        elt "table" ~a:[class_ "table table-hover area-content"] [
          elt "thead" [
            elt "tr" [
              elt "th" ~a:[str_prop "scope" "col"; str_prop "style" "width: 1em;"] [ text "" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "Name" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "Last modified" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "Size" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "" ];
              elt "th" ~a:[str_prop "scope" "col"] [ text "" ];
            ]
          ];
          elt "tbody" (trs_directories @ trs_files)
        ]
      ]]

let breadcrumb_last user area_id e =
  match Com.User.can_do_action ~area_id ~action:Com.Action.create_directory user with
  | true ->
    elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
      div ~a:[class_ "dropdown"] [
        elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm btn-light dropdown-toggle";
                         attr "data-bs-toggle" "dropdown"; attr "aria-expanded" "false"] [
          text e
        ];
        elt "ul" ~a:[class_ "dropdown-menu"] [
          elt "li" [
            elt "a" ~a:[class_ "dropdown-item"; str_prop "href" ""; onclick_cancel (fun e -> Some (Action.New_directory Action_other.New_directory.Ask))] [
              text "New directory"
            ]
          ];
        ]
      ]
    ]
  | false ->
    elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
      div [
        elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm btn-light";
                         attr "aria-expanded" "false"] [
          text e
        ]
      ]
    ]

let breadcrumb_area user area with_menu =
  let area_id = Com.Area.get_id area in
  let area_name = Com.Area.get_name area in
  match with_menu with
  | false ->
    elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
      Html.link (Routing.Page.Area_content (area_id, []))
        ~class_attr:"btn btn-sm btn-light link-underline-light" ~title:"Area" [
        text area_name
      ]
    ]
  | true -> breadcrumb_last user area_id area_name

let breadcrumb user area l =
  let area_id = Com.Area.get_id area in
  match l with
  | [] -> [breadcrumb_area user area true]
  | l ->
    let without_last = List.rev l |> List.tl |> List.rev in
    let only_last = List.rev l |> List.hd in
    let elts, _ = List.fold_left (fun (elts, dirs) e -> (
          elts @ [
            elt "li" ~a:[class_ "breadcrumb-item d-flex align-items-center"] [
              Html.link (Routing.Page.Area_content (area_id, dirs @ [e]))
                ~class_attr:"btn btn-sm btn-light link-underline-light" ~title:e [
                text e
              ]
            ]
          ], dirs @ [e])
      ) ([], []) without_last
    in
    [(breadcrumb_area user area false)] @ elts @ [(breadcrumb_last user area_id only_last)]

let view m =
  if (Block.Fetchable.is_loaded m.Model.block) then (
    let user = m.Model.user in
    let content = m.Model.area_content in
    let area = Com.Area_content.get_area content in
    let area_id = Com.Area.get_id area in
    let subdirs = Com.Area_content.get_subdirs content in
    let directories = Com.Area_content.get_directories content in
    let files = Com.Area_content.get_files content in
    let lines = lines user area_id subdirs directories files in
    let td_delete =
      match Com.User.can_do_action ~area_id ~action:Com.Action.upload user with
      | true -> [
          div ~a:[class_ "col-auto"] [
            elt "form" ~a:[class_ "d-flex"; str_prop "role" "button"] [
              div ~a:[class_ "input-group input-group-sm"] [
                div ~a:[class_ "input-group-text"] [ Icon.file_upload ~class_attr:"" ];
                input ~a:[class_ "form-control form-control-sm"; str_prop "type" "file"; value "";
                          attr "aria-label" "upload"; str_prop "id" "fileupload";
                          oninput (fun e -> Action.Upload_file (Action_other.Upload_file.Start { input_file_id = "fileupload" }))] []
              ]
            ];
          ]
        ]
      | false -> []
    in
    elt "content" [
      div ~a:[class_ "row justify-content-end"] td_delete;
      div ~a:[class_ "row mt-3 mb-3"] [
        div ~a:[class_ "col"] [
          elt "nav" ~a:[class_ ""; attr "aria-label" "breadcrumb"] [
            elt "ol" ~a:[class_ "breadcrumb mt-2 mb-2 align-items-center"] 
              (breadcrumb user area subdirs)
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