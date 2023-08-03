module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Datetime = Shupdofi_srv_datetime.Datetime

let rename config req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let rename_directory = Yojson.Safe.from_string body |> Msg_from_clt.Rename_directory.t_of_yojson in
  let area_id = Msg_from_clt.Rename_directory.get_area_id rename_directory in
  let subdirs = Msg_from_clt.Rename_directory.get_subdirs rename_directory in
  let old_dirname = Msg_from_clt.Rename_directory.get_old_dirname rename_directory in
  let new_dirname = Msg_from_clt.Rename_directory.get_new_dirname rename_directory in
  let area = Com.Area.find_with_id area_id (Config.Config.get_areas config) in
  let relative_dir_old = Content.Directory.make_from_list (subdirs @ [old_dirname]) in
  let relative_dir_new = Content.Directory.make_from_list (subdirs @ [new_dirname]) in
  let rename = Content.Directory.rename (Com.Area.get_root area) ~before:relative_dir_old ~after:relative_dir_new in
  match rename with
  | None ->
    S.Response.fail_raise ~code:403 "Cannot rename directory %s to %s" old_dirname new_dirname
  | Some new_stat ->
    let mtime = new_stat.Unix.LargeFile.st_mtime in
    let old_directory = Com.Directory.make_relative ~name:old_dirname () in
    let new_directory = Com.Directory.make_relative ~name:new_dirname ()
                        |> Com.Directory.set_mdatetime (Some (Datetime.of_mtime mtime))
    in
    let directory_renamed = Msg_to_clt.Directory_renamed.make ~area_id ~subdirs ~old_directory ~new_directory in
    let json = Msg_to_clt.Directory_renamed.yojson_of_t directory_renamed |> Yojson.Safe.to_string in
    S.Response.make_raw ~code:200 json

(* ~accept:(fun req ->
   match S.Request.get_header_int req "Content-Length" with
   | Some n when n > config.max_upload_size ->
    Error (403, "max upload size is " ^ string_of_int config.max_upload_size)
   | Some _ when contains_dot_dot req.S.Request.path ->
    Error (403, "invalid path (contains '..')")
   | _ -> Ok ()
   ) *)
let archive config area_id path req =
  let area = Com.Area.find_with_id area_id (Config.Config.get_areas config) in
  try
    let archive = Content.Path.absolute_from_string (Filename.temp_file "shupdofi" "archive") in
    let () = Content.Archive.create_archive_of_directory ~archive ~root:(Com.Area.get_root area) ~subdir:(Com.Directory.make_relative ~name:path ()) in
    let path_archive = Content.Path.to_string archive in
    let ch = In_channel.open_bin path_archive in
    let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
    let response = S.Response.make_raw_stream ~code:S.Response_code.ok stream |> S.Response.set_header "Content-Type" "application/zip" in
    let () = Sys.remove path_archive in
    response
  with
  | _ ->
    S.Response.fail_raise ~code:403 "Cannot download directory %s" path

(* ~accept:(fun req ->
   match S.Request.get_header_int req "Content-Length" with
   | Some n when n > config.max_upload_size ->
    Error (403, "max upload size is " ^ string_of_int config.max_upload_size)
   | Some _ when contains_dot_dot req.S.Request.path ->
    Error (403, "invalid path (contains '..')")
   | _ -> Ok ()
   ) *)
let create config req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let new_directory = Yojson.Safe.from_string body |> Msg_from_clt.New_directory.t_of_yojson in
  let area_id = Msg_from_clt.New_directory.get_area_id new_directory in
  let subdirs = Msg_from_clt.New_directory.get_subdirs new_directory in
  let dirname = Msg_from_clt.New_directory.get_dirname new_directory in
  let area = Com.Area.find_with_id area_id (Config.Config.get_areas config) in
  let make_dir = Content.Directory.mkdir (Com.Area.get_root area) (subdirs @ [dirname]) in
  match make_dir with
  | None ->
    S.Response.fail_raise ~code:403 "Cannot create directory %s" dirname
  | Some directory ->
    let new_directory_created = Msg_to_clt.New_directory_created.make ~area_id ~subdirs ~directory in
    let json = Msg_to_clt.New_directory_created.yojson_of_t new_directory_created |> Yojson.Safe.to_string in
    S.Response.make_raw ~code:201 json

let delete config req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let delete_directory = Yojson.Safe.from_string body |> Msg_from_clt.Delete_directory.t_of_yojson in
  let area_id = Msg_from_clt.Delete_directory.get_area_id delete_directory in
  let subdirs = Msg_from_clt.Delete_directory.get_subdirs delete_directory in
  let dirname = Msg_from_clt.Delete_directory.get_dirname delete_directory in
  let area = Com.Area.find_with_id area_id (Config.Config.get_areas config) in
  try
    Content.Directory.delete (Com.Area.get_root area)
      (Content.Directory.make_from_list (subdirs @ [dirname]));
    S.Response.make_raw ~code:200 ""
  with
  | _ -> S.Response.fail_raise ~code:403 "Cannot delete directory %s" dirname
