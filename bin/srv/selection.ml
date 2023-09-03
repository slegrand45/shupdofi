module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Datetime = Shupdofi_srv_datetime.Datetime

let archive config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let selection = Yojson.Safe.from_string body |> Msg_from_clt.Selection.t_of_yojson in
  let area_id = Msg_from_clt.Selection.get_area_id selection in
  let area = Config.Config.find_area_with_id area_id config in
  let auth_download = Auth.user_authorized config user area Com.Action.download in
  let auth_archive = Auth.user_authorized config user area Com.Action.archive in
  match auth_download, auth_archive with
  | true, true -> (
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
  | _, _ -> S.Response.fail ~code:403 "Archive and/or download are not authorized"

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
      let file (oks, kos) file =
        try
          Content.Path.delete (Config.Area.get_root area)
            (Com.Path.make_relative (Content.Directory.make_from_list subdirs) (Com.File.make ~name:file ()));
          (file::oks, kos)
        with
        | _ -> (oks, file::kos)
      in
      let (files_ok, files_ko) = List.fold_left file ([], []) filenames in
      let files_ok = List.map (fun e -> Com.File.make ~name:e ()) files_ok in
      let files_ko = List.map (fun e -> Com.File.make ~name:e ()) files_ko in
      let json =
        Msg_to_clt.Selection_processed.make ~area:(Config.Area.get_area area) ~subdirs ~directories_ok ~directories_ko ~files_ok ~files_ko
        |> Msg_to_clt.Selection_processed.yojson_of_t
        |> Yojson.Safe.to_string
      in
      match directories_ok, directories_ko, files_ok, files_ko with
      | _, [], _, [] -> S.Response.make_raw ~code:200 json
      | _, _, _, _ -> S.Response.make_raw ~code:520 json
    )
  | false -> S.Response.fail ~code:403 "Delete is not authorized"