module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Datetime = Shupdofi_srv_datetime.Datetime

let get_max_upload_size area =
  let quota = Config.Area.get_quota area |> snd |> Option.fold ~none:Int64.max_int ~some:Com.Size.to_int64 in
  let current_area_size = Content.Directory.size (Config.Area.get_root area) ~stop:quota in
  Int64.sub quota current_area_size

let archive config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let selection = Yojson.Safe.from_string body |> Msg_from_clt.Selection.t_of_yojson in
  let area_id = Msg_from_clt.Selection.get_area_id selection in
  let area = Config.Config.find_area_with_id area_id config in
  let auth_download = Auth.user_authorized config user area Com.Action.download in
  match auth_download with
  | true -> (
      try
        let subdirs = Msg_from_clt.Selection.get_subdirs selection in
        let path = Content.Directory.make_from_list subdirs in
        let dirnames = Msg_from_clt.Selection.get_dirnames selection in
        let filenames = Msg_from_clt.Selection.get_filenames selection in
        let archive = Content.Path.absolute_from_string (Filename.temp_file "shupdofi" "archive") in
        let () = Content.Archive.create_archive_of_names ~archive ~root:(Config.Area.get_root area) ~subdir:path ~dirnames ~filenames in
        let path_archive = Content.Path.to_string archive in
        let ch = In_channel.open_bin path_archive in
        let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
        let response = S.Response.make_raw_stream ~code:S.Response_code.ok stream
                       |> S.Response.set_header "Content-Type" "application/zip"
        in
        let () = Sys.remove path_archive in
        response
      with
      | _ ->
        S.Response.fail ~code:403 "Cannot download selection"
    )
  | _ -> S.Response.fail ~code:403 "Archive and/or download are not authorized"

let delete config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let selection = Yojson.Safe.from_string body |> Msg_from_clt.Selection.t_of_yojson in
  let area_id = Msg_from_clt.Selection.get_area_id selection in
  let area = Config.Config.find_area_with_id area_id config in
  match Auth.user_authorized config user area Com.Action.delete with
  | true -> (
      let subdirs = Msg_from_clt.Selection.get_subdirs selection in
      let dirnames = Msg_from_clt.Selection.get_dirnames selection in
      let filenames = Msg_from_clt.Selection.get_filenames selection in
      let directory (oks, kos) dir =
        try
          Content.Directory.delete (Config.Area.get_root area)
            (Content.Directory.make_from_list (subdirs @ [dir]));
          (dir::oks, kos)
        with
        | _ -> (oks, dir::kos)
      in
      let (directories_ok, directories_ko) = List.fold_left directory ([], []) dirnames in
      let directories_ok = List.map (fun e -> Com.Directory.make_relative ~name:e ()) directories_ok in
      let directories_ko = List.map (fun e -> Com.Directory.make_relative ~name:e ()) directories_ko in
      let path (oks, kos) file =
        let path = Com.Path.make_relative (Content.Directory.make_from_list subdirs) (Com.File.make ~name:file ()) in
        try
          Content.Path.delete (Config.Area.get_root area) path;
          (path::oks, kos)
        with
        | _ -> (oks, path::kos)
      in
      let (paths_ok, paths_ko) = List.fold_left path ([], []) filenames in
      let json =
        Msg_to_clt.Selection_processed.make ~area:(Config.Area.get_area area) ~subdirs ~directories_ok ~directories_ko ~paths_ok ~paths_ko
        |> Msg_to_clt.Selection_processed.yojson_of_t
        |> Yojson.Safe.to_string
      in
      match directories_ok, directories_ko, paths_ok, paths_ko with
      | _, [], _, [] -> S.Response.make_raw ~code:200 json
      | _, _, _, _ -> S.Response.make_raw ~code:520 json
    )
  | false -> S.Response.fail ~code:403 "Delete is not authorized"

let copy config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let selection = Yojson.Safe.from_string body |> Msg_from_clt.Selection_paste.t_of_yojson in
  let area_id = Msg_from_clt.Selection_paste.get_selection selection |> Msg_from_clt.Selection.get_area_id in
  let area = Config.Config.find_area_with_id area_id config in
  let target_area_id = Msg_from_clt.Selection_paste.get_target_area_id selection in
  let target_area = Config.Config.find_area_with_id target_area_id config in
  match Auth.user_authorized config user area Com.Action.download, Auth.user_authorized config user target_area Com.Action.upload with
  | true, true -> (
      let subdirs = Msg_from_clt.Selection_paste.get_selection selection |> Msg_from_clt.Selection.get_subdirs in
      let dirnames = Msg_from_clt.Selection_paste.get_selection selection |> Msg_from_clt.Selection.get_dirnames in
      let filenames = Msg_from_clt.Selection_paste.get_selection selection |> Msg_from_clt.Selection.get_filenames in
      let target_subdirs = Msg_from_clt.Selection_paste.get_target_subdirs selection in
      let f_tree_file acc dir =
        let tree = Content.Path.tree ~root:(Config.Area.get_root area) ~subdir:(Content.Directory.make_from_list subdirs)
            ~dir:(Content.Directory.make_from_list [dir])
        in
        acc @ tree
      in
      let tree_file = List.fold_left f_tree_file [] dirnames in
      let files =
        List.map (fun e -> Com.Path.make_relative (Com.Directory.make_relative ~name:"" ()) (Com.File.make ~name:e ())) filenames
      in
      let tree_file = tree_file @ files in
      let total_size_files = Content.Path.size_of_tree ~tree:tree_file ~root:(Config.Area.get_root area) ~subdir:(Content.Directory.make_from_list subdirs) in
      let max_upload_size = get_max_upload_size area in
      match max_upload_size > 0L && total_size_files <= max_upload_size with
      | true -> (
          let f_tree_dir acc dir =
            let tree = Content.Directory.tree ~root:(Config.Area.get_root area) ~subdir:(Content.Directory.make_from_list subdirs)
                ~dir:(Content.Directory.make_from_list [dir])
            in
            acc @ tree
          in
          let tree_dir = List.fold_left f_tree_dir [] dirnames in
          let dir_creation = Content.Directory.create_from_tree ~tree:tree_dir
              ~root:(Config.Area.get_root target_area) ~subdir:(Content.Directory.make_from_list target_subdirs)
          in
          let directories_ok = List.filter Result.is_ok dir_creation |> List.map Result.get_ok in
          let directories_ko = List.filter Result.is_error dir_creation |> List.map Result.get_error in
          let overwrite = Msg_from_clt.Selection_paste.get_overwrite selection in
          let file_copy = Content.Path.copy_from_tree ~overwrite ~tree:tree_file
              ~from_root:(Config.Area.get_root area) ~from_subdir:(Content.Directory.make_from_list subdirs)
              ~to_root:(Config.Area.get_root target_area) ~to_subdir:(Content.Directory.make_from_list target_subdirs)
          in
          let paths_ok = List.filter Result.is_ok file_copy |> List.map Result.get_ok in
          (* client only needs "root" files for oks *)
          let paths_ok = List.filter (fun e -> (Com.Path.get_directory e |> Option.get |> Com.Directory.get_name) = "") paths_ok in
          let paths_ko = List.filter Result.is_error file_copy |> List.map Result.get_error in
          let processed = Msg_to_clt.Selection_processed.make ~area:(Config.Area.get_area area) ~subdirs ~directories_ok ~directories_ko ~paths_ok ~paths_ko in
          let json =
            Msg_to_clt.Selection_paste_processed.make ~selection:processed ~target_area:(Config.Area.get_area target_area) ~target_subdirs
            |> Msg_to_clt.Selection_paste_processed.yojson_of_t
            |> Yojson.Safe.to_string
          in
          match directories_ok, directories_ko, paths_ok, paths_ko with
          | _, [], _, [] -> S.Response.make_raw ~code:200 json
          | _, _, _, _ -> S.Response.make_raw ~code:520 json
        )
      | false ->
        S.Response.fail ~code:403 "Area quota exceeded"
    )
  | _, _ -> S.Response.fail ~code:403 "Copy is not authorized"
