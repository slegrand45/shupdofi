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
module Sorting = Com.Sorting
module T = Shupdofi_clt_i18n.T

open Vdom

let one_line_size_bytes v =
  let bytes = Com.File.get_size_bytes v in
  match bytes with
  | None -> ""
  | Some v -> Size.(to_human (from_int64 v))

let one_line_mdatetime v =
  match v with
  | None -> ""
  | Some v -> Intl.fmt_date_hm v

let one_line_directory prefs selection user area subdirs (acc, i) directory =
  let area_id = Com.Area.get_id area in
  let dirname = Com.Directory.get_name directory in
  let href_download = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Download_directory { area_id; subdirs; dirname })) in
  let td_download =
    match Com.User.can_do_action ~area_id ~action:Com.Action.download user with
    | true -> [
        elt "a" ~a:[str_prop "href" href_download; class_ "action hide"; str_prop "download" ""] [
          Icon.file_download ~label:(T._t prefs Download) ~class_attr:"icon" ~aria_id:("directory-icon-title-file-download" ^ (string_of_int i))
        ];
      ]
    | _ -> []
  in
  let td_rename =
    match Com.User.can_do_action ~area_id ~action:Com.Action.rename user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Rename_directory (Action_other.Rename_directory.Ask { directory })))] [
          Icon.edit ~label:(T._t prefs Rename) ~class_attr:"icon" ~aria_id:("directory-icon-title-edit" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  let td_delete =
    match Com.User.can_do_action ~area_id ~action:Com.Action.delete user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Delete_directory (Action_other.Delete_directory.Ask { directory })))] [
          Icon.delete_forever ~label:(T._t prefs Delete) ~class_attr:"icon" ~aria_id:("directory-icon-delete-forever" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  match Com.Directory.get_name directory with
  | "" -> (acc, i + 1)
  | name -> (
      elt "tr" ~a:[class_ "line"] [
        elt "td" [
          elt "input" ~a:[type_ "checkbox"; class_ "line form-check-input"; attr "aria-label" (T._t prefs Select_directory);
                          bool_prop "checked" (Com.Selection.directory_is_selected ~area ~subdirs ~directory selection);
                          onclick (fun _ -> Action.Click_select_directory { area; subdirs; directory })] []
        ];
        elt "td" [ Icon.folder ~class_attr:"" ];
        elt "td" ~a:[onclick_cancel (fun _ -> Some (Action.Area_go_to_subdir { name }))] [ text name ];
        elt "td" [ text (one_line_mdatetime (Com.Directory.get_mdatetime directory)) ];
        elt "td" [ text "" ];
        elt "td" ~a:[class_ "text-center"] td_download;
        elt "td" ~a:[class_ "text-center"] td_rename;
        elt "td" ~a:[class_ "text-center"] td_delete;
      ] :: acc, i + 1)

let one_line_file prefs selection user area subdirs (acc, i) file =
  let area_id = Com.Area.get_id area in
  let filename = Com.File.get_name file in
  let href_download = Routing.Api.(to_url ~encode:(fun e -> Js_of_ocaml.Js.(to_string (encodeURIComponent (string e)))) (Download_file { area_id; subdirs; filename })) in
  let td_download =
    match Com.User.can_do_action ~area_id ~action:Com.Action.download user with
    | true -> [
        elt "a" ~a:[str_prop "href" href_download; class_ "action hide"; str_prop "download" ""] [
          Icon.file_download ~label:(T._t prefs Download) ~class_attr:"icon" ~aria_id:("file-icon-title-file-download" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  let td_rename =
    match Com.User.can_do_action ~area_id ~action:Com.Action.rename user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Rename_file (Action_other.Rename_file.Ask { file })))] [
          Icon.edit ~label:(T._t prefs Rename) ~class_attr:"icon" ~aria_id:("file-icon-title-edit" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  let td_delete =
    match Com.User.can_do_action ~area_id ~action:Com.Action.delete user with
    | true -> [
        elt "a" ~a:[str_prop "href" ""; class_ "action hide";
                    onclick_cancel (fun _ -> Some (Action.Delete_file (Action_other.Delete_file.Ask { file })))] [
          Icon.delete_forever ~label:(T._t prefs Delete) ~class_attr:"icon" ~aria_id:("file-icon-delete-forever" ^ (string_of_int i))
        ];
      ]
    | false -> []
  in
  match Com.File.get_name file with
  | "" -> (acc, i + 1)
  | name -> (
      elt "tr" ~a:[class_ "line"] [
        elt "td" [
          elt "input" ~a:[type_ "checkbox"; class_ "line form-check-input"; attr "aria-label" (T._t prefs Select_file);
                          bool_prop "checked" (Com.Selection.file_is_selected ~area ~subdirs ~file selection);
                          onclick (fun _ -> Action.Click_select_file { area; subdirs; file })] []
        ];
        elt "td" [ text "" ];
        elt "td" [ text name ];
        elt "td" [ text (one_line_mdatetime (Com.File.get_mdatetime file)) ];
        elt "td" [ text (one_line_size_bytes file) ];
        elt "td" ~a:[class_ "text-center"] td_download;
        elt "td" ~a:[class_ "text-center"] td_rename;
        elt "td" ~a:[class_ "text-center"] td_delete;
      ] :: acc, i + 1)

let icon_sort prefs sorting criteria =
  let icon ~aria_id ~visible =
    let class_attr = if visible then "icon" else "icon invisible" in
    match Sorting.get_direction sorting with
    | Sorting.Direction.Ascending ->
      Icon.arrow_upward ~label:(T._t prefs Sort_upward) ~class_attr ~aria_id:(aria_id ^ "-icon-arrow-upward")
    | Sorting.Direction.Descending ->
      Icon.arrow_downward ~label:(T._t prefs Sort_downward) ~class_attr ~aria_id:(aria_id ^ "-icon-arrow-downward")
  in
  match criteria with
  | Sorting.Criteria.Name -> (
      match Sorting.get_criteria sorting with
      | Sorting.Criteria.Name -> [ icon ~aria_id:("name") ~visible:true ]
      | _ -> [ icon ~aria_id:("name") ~visible:false ]
    )
  | Sorting.Criteria.Last_modified -> (
      match Sorting.get_criteria sorting with
      | Sorting.Criteria.Last_modified -> [ icon ~aria_id:("lastmodified") ~visible:true ]
      | _ -> [ icon ~aria_id:("lastmodified") ~visible:false ]
    )
  | Sorting.Criteria.Size -> (
      match Sorting.get_criteria sorting with
      | Sorting.Criteria.Size -> [ icon ~aria_id:("size") ~visible:true ]
      | _ -> [ icon ~aria_id:("size") ~visible:false ]
    )

let lines prefs sorting selection user area subdirs directories files =
  match directories, files with
  | [], [] -> [elt "p"
                 [ text "Empty directory" ]
              ]
  | directories, files ->
    let trs_directories = List.fold_left (one_line_directory prefs selection user area subdirs) ([], 1) directories |> fst |> List.rev in
    let trs_files = List.fold_left (one_line_file prefs selection user area subdirs) ([], 1) files |> fst |> List.rev in
    [div ~a:[class_ "table-responsive"] [
        elt "table" ~a:[class_ "table table-hover area-content"] [
          elt "thead" [
            elt "tr" [
              elt "th" [
                elt "input" ~a:[type_ "checkbox"; class_ "line form-check-input"; attr "aria-label" (T._t prefs Select_all);
                                bool_prop "checked" (Com.Selection.all_is_selected ~area ~subdirs selection);
                                onclick (fun _ -> Action.Click_select_all { area; subdirs; directories; files })] []
              ];
              elt "th" ~a:[str_prop "scope" "col"; str_prop "style" "width: 1em;"] [ text "" ];
              elt "th" ~a:[str_prop "scope" "col"] [
                elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm btn-light";
                                 attr "aria-expanded" "false";
                                 onclick (fun _ -> Action.Click_sorting Sorting.Criteria.name)] [
                  elt "span" ~a:[] [ text (T._t prefs Name) ];
                  elt "span" ~a:[ class_ "px-2" ] (icon_sort prefs sorting Sorting.Criteria.name)
                ]
              ];
              elt "th" ~a:[str_prop "scope" "col"] [
                elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm btn-light";
                                 attr "aria-expanded" "false";
                                 onclick (fun _ -> Action.Click_sorting Sorting.Criteria.last_modified)] [
                  elt "span" ~a:[] [ text (T._t prefs Last_modified) ];
                  elt "span" ~a:[ class_ "px-2" ] (icon_sort prefs sorting Sorting.Criteria.last_modified)
                ]
              ];
              elt "th" ~a:[str_prop "scope" "col"] [
                elt "button" ~a:[str_prop "type" "button"; class_ "btn btn-sm btn-light";
                                 attr "aria-expanded" "false";
                                 onclick (fun _ -> Action.Click_sorting Sorting.Criteria.size)] [
                  elt "span" ~a:[] [ text (T._t prefs Size) ];
                  elt "span" ~a:[ class_ "px-2" ] (icon_sort prefs sorting Sorting.Criteria.size)
                ]
              ];
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
            elt "a" ~a:[class_ "dropdown-item"; str_prop "href" ""; onclick_cancel (fun _ -> Some (Action.New_directory Action_other.New_directory.Ask))] [
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
    let prefs = m.Model.preferences in
    let user = m.Model.user in
    let content = m.Model.area_content |> Com.Area_content.sort m.sorting in
    let sorting = m.Model.sorting in
    let selection = m.Model.selection in
    let area = Com.Area_content.get_area content in
    let area_id = Com.Area.get_id area in
    let subdirs = Com.Area_content.get_subdirs content in
    let directories = Com.Area_content.get_directories content in
    let files = Com.Area_content.get_files content in
    let lines = lines prefs sorting selection user area subdirs directories files in
    let td_delete =
      match Com.User.can_do_action ~area_id ~action:Com.Action.upload user with
      | true -> [
          div ~a:[class_ "col-auto"] [
            elt "form" ~a:[class_ "d-flex"; str_prop "role" "button"] [
              div ~a:[class_ "input-group input-group-sm"] [
                div ~a:[class_ "input-group-text"] [ Icon.file_upload ~class_attr:"" ];
                input ~a:[class_ "form-control form-control-sm"; str_prop "type" "file"; value "";
                          attr "aria-label" (T._t prefs Upload); str_prop "id" "fileupload"; bool_prop "multiple" true;
                          oninput (fun _ -> Action.Upload_file (Action_other.Upload_file.Start { input_file_id = "fileupload" }))] []
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
          elt "nav" ~a:[class_ ""; attr "aria-label" (T._t prefs Breadcrumb)] [
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