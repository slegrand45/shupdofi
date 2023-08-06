module Com = Shupdofi_com
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module S = Tiny_httpd

let upload config area_id path req =
  let path_string = path in
  let area = Config.Config.find_area_with_id area_id config in
  let path = Content.Path.relative_from_string path in
  let path = Content.Path.next_if_exists (Config.Area.get_root area) path in
  let write, close =
    try
      Content.Path.oc (Config.Area.get_root area) path
    with e ->
      S.Response.fail_raise ~code:403 "Cannot upload %S: %s"
        path_string (Printexc.to_string e)
  in
  let () = Tiny_httpd_stream.iter write req.S.Request.body in
  let () = close () in
  let path = Content.Path.update_meta_infos (Config.Area.get_root area) path in
  let directory = Com.Path.get_directory path in
  let file = Com.Path.get_file path in
  let json =
    match directory, file with
    | Some d, Some f -> 
      let uploaded = Msg_to_clt.Uploaded.make ~area_id ~subdirs:(Content.Directory.to_list_of_string d) ~file:f in
      Msg_to_clt.Uploaded.yojson_of_t uploaded  |> Yojson.Safe.to_string
    | _ -> ""
  in
  S.Response.make_raw ~code:201 json

let rename config req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let rename_file = Yojson.Safe.from_string body |> Msg_from_clt.Rename_file.t_of_yojson in
  let area_id = Msg_from_clt.Rename_file.get_area_id rename_file in
  let subdirs = Msg_from_clt.Rename_file.get_subdirs rename_file in
  let old_filename = Msg_from_clt.Rename_file.get_old_filename rename_file in
  let new_filename = Msg_from_clt.Rename_file.get_new_filename rename_file in
  let area = Config.Config.find_area_with_id area_id config in
  let relative_path_old = Com.Path.make_relative (Content.Directory.make_from_list subdirs) (Com.File.make ~name:old_filename ()) in
  let relative_path_new = Com.Path.make_relative (Content.Directory.make_from_list subdirs) (Com.File.make ~name:new_filename ()) in
  let rename = Content.Path.rename (Config.Area.get_root area) ~before:relative_path_old ~after:relative_path_new in
  match rename with
  | None ->
    S.Response.fail_raise ~code:403 "Cannot rename file %s to %s" old_filename new_filename
  | Some (old_file, new_file) ->
    let file_renamed = Msg_to_clt.File_renamed.make ~area_id ~subdirs ~old_file ~new_file in
    let json = Msg_to_clt.File_renamed.yojson_of_t file_renamed |> Yojson.Safe.to_string in
    S.Response.make_raw ~code:200 json

let download config area_id path req =
  let path_string = path in
  let area = Config.Config.find_area_with_id area_id config in
  let path = Content.Path.relative_from_string path in
  let dir = Com.Path.get_directory path in
  let file = Com.Path.get_file path in
  match dir, file with
  | Some dir, Some file -> (
      let path = Com.Path.make_absolute (Content.Directory.concat (Config.Area.get_root area) dir) file in
      let ch = In_channel.open_bin (Content.Path.to_string path) in
      let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
      S.Response.make_raw_stream ~code:S.Response_code.ok stream
      |> S.Response.set_header "Content-Type" (Content.Path.mime path)
    )
  | _, _ ->
    S.Response.fail_raise ~code:403 "Cannot download %s" path_string

let delete config req =
  let body = Tiny_httpd_stream.read_all req.S.Request.body in
  let delete_file = Yojson.Safe.from_string body |> Msg_from_clt.Delete_file.t_of_yojson in
  let area_id = Msg_from_clt.Delete_file.get_area_id delete_file in
  let subdirs = Msg_from_clt.Delete_file.get_subdirs delete_file in
  let filename = Msg_from_clt.Delete_file.get_filename delete_file in
  let area = Config.Config.find_area_with_id area_id config in
  try
    Content.Path.delete (Config.Area.get_root area)
      (Com.Path.make_relative (Content.Directory.make_from_list subdirs) (Com.File.make ~name:filename ()));
    S.Response.make_raw ~code:200 ""
  with
  | _ -> S.Response.fail_raise ~code:403 "Cannot delete file %s" filename      
