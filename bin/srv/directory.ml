module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Datetime = Shupdofi_srv_datetime.Datetime

let rename config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let rename_directory = Yojson.Safe.from_string body |> Msg_from_clt.Rename_directory.t_of_yojson in
  let area_id = Msg_from_clt.Rename_directory.get_area_id rename_directory in
  let area = Config.Config.find_area_with_id area_id config in
  match Auth.user_authorized config user area Com.Action.rename with
  | true -> (
      let subdirs = Msg_from_clt.Rename_directory.get_subdirs rename_directory in
      let old_dirname = Msg_from_clt.Rename_directory.get_old_dirname rename_directory in
      let new_dirname = Msg_from_clt.Rename_directory.get_new_dirname rename_directory in
      let relative_dir_old = Content.Directory.make_from_list (subdirs @ [old_dirname]) in
      let relative_dir_new = Content.Directory.make_from_list (subdirs @ [new_dirname]) in
      let rename = Content.Directory.rename (Config.Area.get_root area) ~before:relative_dir_old ~after:relative_dir_new in
      match rename with
      | None ->
        S.Response.fail ~code:403 "Cannot rename directory %s to %s" old_dirname new_dirname
      | Some new_stat ->
        let mtime = new_stat.Unix.LargeFile.st_mtime in
        let old_directory = Com.Directory.make_relative ~name:old_dirname () in
        let new_directory = Com.Directory.make_relative ~name:new_dirname ()
                            |> Com.Directory.set_mdatetime (Some (Datetime.of_mtime mtime))
        in
        let directory_renamed = Msg_to_clt.Directory_renamed.make ~area_id ~subdirs ~old_directory ~new_directory in
        let json = Msg_to_clt.Directory_renamed.yojson_of_t directory_renamed |> Yojson.Safe.to_string in
        Response.json json ~code:200 ~req
    )
  | false -> S.Response.fail ~code:403 "Rename is not authorized"

(* ~accept:(fun req ->
   match S.Request.get_header_int req "Content-Length" with
   | Some n when n > config.max_upload_size ->
    Error (403, "max upload size is " ^ string_of_int config.max_upload_size)
   | Some _ when contains_dot_dot req.S.Request.path ->
    Error (403, "invalid path (contains '..')")
   | _ -> Ok ()
   ) *)
let archive config user area_id path =
  let area = Config.Config.find_area_with_id area_id config in
  let auth_download = Auth.user_authorized config user area Com.Action.download in
  match auth_download with
  | true -> (
      try
        let archive = Content.Path.absolute_from_string (Filename.temp_file "shupdofi" "archive") in
        let () = Content.Archive.create_archive_of_directory ~archive ~root:(Config.Area.get_root area) ~subdir:(Com.Directory.make_relative ~name:path ()) in
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
        S.Response.fail ~code:403 "Cannot download directory %s" path
    )
  | _ -> S.Response.fail ~code:403 "Archive and/or download are not authorized"

(* ~accept:(fun req ->
   match S.Request.get_header_int req "Content-Length" with
   | Some n when n > config.max_upload_size ->
    Error (403, "max upload size is " ^ string_of_int config.max_upload_size)
   | Some _ when contains_dot_dot req.S.Request.path ->
    Error (403, "invalid path (contains '..')")
   | _ -> Ok ()
   ) *)
let create config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let new_directory = Yojson.Safe.from_string body |> Msg_from_clt.New_directory.t_of_yojson in
  let area_id = Msg_from_clt.New_directory.get_area_id new_directory in
  let area = Config.Config.find_area_with_id area_id config in
  match Auth.user_authorized config user area Com.Action.create_directory with
  | true -> (
      let subdirs = Msg_from_clt.New_directory.get_subdirs new_directory in
      let dirname = Msg_from_clt.New_directory.get_dirname new_directory in
      let make_dir = Content.Directory.mkdir (Config.Area.get_root area) (subdirs @ [dirname]) in
      match make_dir with
      | None ->
        S.Response.fail ~code:403 "Cannot create directory %s" dirname
      | Some directory ->
        let new_directory_created = Msg_to_clt.New_directory_created.make ~area_id ~subdirs ~directory in
        let json = Msg_to_clt.New_directory_created.yojson_of_t new_directory_created |> Yojson.Safe.to_string in
        Response.json json ~code:201 ~req
    )
  | false -> S.Response.fail ~code:403 "Directory creation is not authorized"

let delete config user req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let delete_directory = Yojson.Safe.from_string body |> Msg_from_clt.Delete_directory.t_of_yojson in
  let area_id = Msg_from_clt.Delete_directory.get_area_id delete_directory in
  let area = Config.Config.find_area_with_id area_id config in
  match Auth.user_authorized config user area Com.Action.delete with
  | true -> (
      let subdirs = Msg_from_clt.Delete_directory.get_subdirs delete_directory in
      let dirname = Msg_from_clt.Delete_directory.get_dirname delete_directory in
      try
        Content.Directory.delete (Config.Area.get_root area)
          (Content.Directory.make_from_list (subdirs @ [dirname]));
        S.Response.make_raw ~code:200 ""
      with
      | _ -> S.Response.fail ~code:403 "Cannot delete directory %s" dirname
    )
  | false -> S.Response.fail ~code:403 "Delete is not authorized"
