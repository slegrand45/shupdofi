module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Srv = Shupdofi_srv

(* cat bombardier-linux-amd64 | curl -vvvv -X PUT --data-binary @- http://127.0.0.1:8080/api/upload/xxx *)

let () =
  let www_root =
    Com.Directory.make_absolute ~name:"/home/slegrand45/depots-git/perso/shupdofi/www/" ();
  in
  let config = Srv.Config.make ~www_root in
  let www_root = Srv.Config.get_www_root config in
  let server = S.create () in

  let accept_gzip (req:_ S.Request.t) =
    match
      S.Request.get_header req "Accept-Encoding"
    with
    | Some s -> List.mem "gzip" @@ String.split_on_char ',' (String.trim s)
    | None -> false
  in

  let gzip_path_if_exists subdir path _req =
    let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Filename.concat (Com.Directory.get_name www_root) subdir) ())
        (Com.File.make ~name:(Filename.basename path) ()) in
    let path_gzip = Srv.Path.add_extension "gz" path in
    if (accept_gzip _req) && (Srv.Path.(retrieve_stat path_gzip |> usable)) then
      (path_gzip, fun r -> S.Response.set_header "Content-Encoding" "gzip" r)
    else
      (path, fun r -> r)
  in

  S.set_top_handler 
    server
    (fun _req ->
       let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
           (Com.File.make ~name:"index.html" ()) in
       let ch = In_channel.open_bin (Srv.Path.to_string path) in
       let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
       S.Response.make_raw_stream ~code:S.Response_code.ok stream
       |> S.Response.set_header "Content-Type" "text/html"
    );

  (* static files *)
  S.add_route_handler ~meth:`GET server
    S.Route.(exact "www" @/ string_urlencoded @/ return)
    (fun path _req ->
       (* ajouter une méthode concat dans Shupdofi_srv.Directory *)
       let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Filename.concat (Com.Directory.get_name www_root) (Filename.dirname path)) ())
           (Com.File.make ~name:(Filename.basename path) ()) in
       let ch = In_channel.open_bin (Srv.Path.to_string path) in
       let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
       S.Response.make_raw_stream ~code:S.Response_code.ok stream
       |> S.Response.set_header "Content-Type" (Srv.Path.mime path)
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "css" @/ string_urlencoded @/ return)
    (fun path _req -> (
         let (path, f_header) = gzip_path_if_exists "css" path _req in
         S.Response.make_string (Ok (In_channel.with_open_bin (Srv.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/css"
         |> f_header
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "js" @/ string_urlencoded @/ return)
    (fun path _req -> (
         let (path, f_header) = gzip_path_if_exists "js" path _req in
         S.Response.make_string (Ok (In_channel.with_open_bin (Srv.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/javascript"
         |> f_header
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "favicon.ico" @/ return)
    (fun _req -> (
         let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
             (Com.File.make ~name:"favicon.ico" ()) in
         S.Response.make_string (Ok (In_channel.with_open_bin (Srv.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "image/vnd.microsoft.icon"
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "robots.txt" @/ return)
    (fun _req -> (
         let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
             (Com.File.make ~name:"robots.txt" ()) in
         S.Response.make_string (Ok (In_channel.with_open_bin (Srv.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/plain"
       )
    );

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "file" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun area_id path req ->
       let path_string = path in
       let area = Com.Area.find_with_id area_id (Srv.Area.get_all ()) in
       let path = Srv.Path.relative_from_string path in
       let write, close =
         try
           Srv.Path.oc (Com.Area.get_root area) path
         with e ->
           S.Response.fail_raise ~code:403 "Cannot upload %S: %s"
             path_string (Printexc.to_string e)
       in
       let () = Tiny_httpd_stream.iter write req.S.Request.body in
       let () = close () in
       let path = Srv.Path.update_meta_infos (Com.Area.get_root area) path in
       let directory = Com.Path.get_directory path in
       let file = Com.Path.get_file path in
       let json =
         match directory, file with
         | Some d, Some f -> 
           let uploaded = Msg_to_clt.Uploaded.make ~area_id ~subdirs:(Srv.Directory.to_list_of_string d) ~file:f in
           Msg_to_clt.Uploaded.yojson_of_t uploaded  |> Yojson.Safe.to_string
         | _ -> ""
       in
       S.Response.make_raw ~code:201 json
    );

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "file" @/ exact "rename" @/ return)
    (fun req ->
       let body = Tiny_httpd_stream.read_all req.S.Request.body in
       let rename_file = Yojson.Safe.from_string body |> Msg_from_clt.Rename_file.t_of_yojson in
       let area_id = Msg_from_clt.Rename_file.get_area_id rename_file in
       let subdirs = Msg_from_clt.Rename_file.get_subdirs rename_file in
       let old_filename = Msg_from_clt.Rename_file.get_old_filename rename_file in
       let new_filename = Msg_from_clt.Rename_file.get_new_filename rename_file in
       let area = Com.Area.find_with_id area_id (Srv.Area.get_all ()) in
       let relative_path_old = Com.Path.make_relative (Srv.Directory.make_from_list subdirs) (Com.File.make ~name:old_filename ()) in
       let relative_path_new = Com.Path.make_relative (Srv.Directory.make_from_list subdirs) (Com.File.make ~name:new_filename ()) in
       let rename = Srv.Path.rename (Com.Area.get_root area) ~before:relative_path_old ~after:relative_path_new in
       match rename with
       | None ->
         S.Response.fail_raise ~code:403 "Cannot rename file %s to %s" old_filename new_filename
       | Some (old_file, new_file) ->
         let file_renamed = Msg_to_clt.File_renamed.make ~area_id ~subdirs ~old_file ~new_file in
         let json = Msg_to_clt.File_renamed.yojson_of_t file_renamed |> Yojson.Safe.to_string in
         S.Response.make_raw ~code:200 json
    );

  S.add_route_handler_stream ~meth:`GET server
    S.Route.(exact "api" @/ exact "file" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun area_id path req ->
       let path_string = path in
       let area = Com.Area.find_with_id area_id (Srv.Area.get_all ()) in
       let path = Srv.Path.relative_from_string path in
       let dir = Com.Path.get_directory path in
       let file = Com.Path.get_file path in
       match dir, file with
       | Some dir, Some file -> (
           let path = Com.Path.make_absolute (Srv.Directory.concat (Com.Area.get_root area) dir) file in
           let ch = In_channel.open_bin (Srv.Path.to_string path) in
           let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
           S.Response.make_raw_stream ~code:S.Response_code.ok stream
           |> S.Response.set_header "Content-Type" (Srv.Path.mime path)
         )
       | _, _ ->
         S.Response.fail_raise ~code:403 "Cannot download %s" path_string
    );

  S.add_route_handler_stream ~meth:`DELETE server
    S.Route.(exact "api" @/ exact "file" @/ return)
    (fun req ->
       let body = Tiny_httpd_stream.read_all req.S.Request.body in
       let delete_file = Yojson.Safe.from_string body |> Msg_from_clt.Delete_file.t_of_yojson in
       let area_id = Msg_from_clt.Delete_file.get_area_id delete_file in
       let subdirs = Msg_from_clt.Delete_file.get_subdirs delete_file in
       let filename = Msg_from_clt.Delete_file.get_filename delete_file in
       let area = Com.Area.find_with_id area_id (Srv.Area.get_all ()) in
       try
         Srv.Path.delete (Com.Area.get_root area)
           (Com.Path.make_relative (Srv.Directory.make_from_list subdirs) (Com.File.make ~name:filename ()));
         S.Response.make_raw ~code:200 ""
       with
       | _ -> S.Response.fail_raise ~code:403 "Cannot delete file %s" filename         
    );

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "directory" @/ return)
    (* ~accept:(fun req ->
       match S.Request.get_header_int req "Content-Length" with
       | Some n when n > config.max_upload_size ->
        Error (403, "max upload size is " ^ string_of_int config.max_upload_size)
       | Some _ when contains_dot_dot req.S.Request.path ->
        Error (403, "invalid path (contains '..')")
       | _ -> Ok ()
       ) *)
    (fun req ->
       let body = Tiny_httpd_stream.read_all req.S.Request.body in
       let new_directory = Yojson.Safe.from_string body |> Msg_from_clt.New_directory.t_of_yojson in
       let area_id = Msg_from_clt.New_directory.get_area_id new_directory in
       let subdirs = Msg_from_clt.New_directory.get_subdirs new_directory in
       let dirname = Msg_from_clt.New_directory.get_dirname new_directory in
       let area = Com.Area.find_with_id area_id (Srv.Area.get_all ()) in
       let make_dir = Srv.Directory.mkdir (Com.Area.get_root area) (subdirs @ [dirname]) in
       match make_dir with
       | None ->
         S.Response.fail_raise ~code:403 "Cannot create directory %s" dirname
       | Some directory ->
         let new_directory_created = Msg_to_clt.New_directory_created.make ~area_id ~subdirs ~directory in
         let json = Msg_to_clt.New_directory_created.yojson_of_t new_directory_created |> Yojson.Safe.to_string in
         S.Response.make_raw ~code:201 json
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact_path "api/areas" return)
    (fun _req -> (
         let v1_areas = Srv.Area.get_all () in
         S.Response.make_string (Ok (Com.Area.yojson_of_collection v1_areas |> Yojson.Safe.to_string))
         |> S.Response.set_header "Content-Type" "text/json"
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "api" @/ exact "area" @/ exact "content" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun id subdirs _req -> (
         (* prerr_endline "** Headers:";
            S.Headers.pp Format.err_formatter (S.Request.headers _req) ;
            prerr_endline "** **"; *)
         match id with
         | "" ->
           S.Response.make_raw ~code:404 "Not found"
         | _ ->
           let subdirs = String.split_on_char '/' subdirs |> List.filter (fun e -> e <> "") in
           let content = Srv.Area.get_content ~id ~subdirs in
           S.Response.make_string (Ok (Com.Area_content.yojson_of_t content |> Yojson.Safe.to_string))
           |> S.Response.set_header "Content-Type" "text/json"
       )
    );

  (* run the server *)
  Printf.printf "listening on http://%s:%d\n%!" (S.addr server) (S.port server);
  match S.run server with
  | Ok () -> ()
  | Error e -> raise e
