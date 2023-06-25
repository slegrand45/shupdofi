module S = Tiny_httpd
module Com = Shupdofi_com
module Srv = Shupdofi_srv

(* cat bombardier-linux-amd64 | curl -vvvv -X PUT --data-binary @- http://127.0.0.1:8080/api/upload/xxx *)

let () =
  let www_root =
    Com.Directory.make ~name:"/home/slegrand45/TMP/ocaml/shupdofi/shupdofi/www/" ();
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
    let path = Com.Path.make (Com.Directory.make ~name:(Filename.concat (Com.Directory.get_name www_root) subdir) ())
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
       let path = Com.Path.make (Com.Directory.make ~name:(Com.Directory.get_name www_root) ())
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
       let path = Com.Path.make (Com.Directory.make ~name:(Filename.concat (Com.Directory.get_name www_root) (Filename.dirname path)) ())
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
         let path = Com.Path.make (Com.Directory.make ~name:(Com.Directory.get_name www_root) ())
             (Com.File.make ~name:"favicon.ico" ()) in
         S.Response.make_string (Ok (In_channel.with_open_bin (Srv.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "image/vnd.microsoft.icon"
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "robots.txt" @/ return)
    (fun _req -> (
         let path = Com.Path.make (Com.Directory.make ~name:(Com.Directory.get_name www_root) ())
             (Com.File.make ~name:"robots.txt" ()) in
         S.Response.make_string (Ok (In_channel.with_open_bin (Srv.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/plain"
       )
    );

  (* file upload *)
  (*
  S.add_route_handler ~meth:`OPTIONS server
    S.Route.(exact "api" @/ exact "upload" @/ string_urlencoded @/ string_urlencoded @/ return)
    (fun _ _ _ _ ->
       prerr_endline "api upload options";
       S.Response.make_raw ~code:200 ""
       |> S.Response.set_header "Access-Control-Allow-Origin" "*"
       |> S.Response.set_header "Access-Control-Allow-Credentials" "true"
       |> S.Response.set_header "Access-Control-Max-Age" "1800"
       |> S.Response.set_header "Access-Control-Allow-Methods" "PUT, POST, GET, DELETE, PATCH, OPTIONS"
       |> S.Response.set_header "Access-Control-Allow-Headers" "content-type"
       |> S.Response.set_header "Access-Control-Allow-Headers" "X-Shupdofi-Data"
    );
    *)
    (*
  S.add_route_handler_stream ~meth:`PUT server
    S.Route.(exact "upload" @/ string_urlencoded @/ return)
    (fun path req ->
       try
         let oc = open_out @@ "/tmp/" ^ path in
         output_string oc (Tiny_httpd_stream.read_all req.S.Request.body);
         flush oc;
         S.Response.make_raw ~code:201 ""
       with e ->
         S.Response.fail ~code:500 "couldn't upload file: %s"
           (Printexc.to_string e)
    ); *)

  S.add_route_handler_stream ~meth:`PUT server
    S.Route.(exact "api" @/ exact "upload" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (* ~accept:(fun req ->
       match S.Request.get_header_int req "Content-Length" with
       | Some n when n > config.max_upload_size ->
        Error (403, "max upload size is " ^ string_of_int config.max_upload_size)
       | Some _ when contains_dot_dot req.S.Request.path ->
        Error (403, "invalid path (contains '..')")
       | _ -> Ok ()
       ) *)
    (fun area_id path req ->
       let path_string = path in
       let area = Com.Area.find_with_id area_id (Srv.Area.get_all ()) in
       let path = Srv.Path.from_string path in
       let write, close =
         try
           Srv.Path.io (Com.Area.get_root area) path          
         with e ->
           S.Response.fail_raise ~code:403 "Cannot upload %S: %s"
             path_string (Printexc.to_string e)
       in
       Tiny_httpd_stream.iter write req.S.Request.body;
       close ();
       let path = Srv.Path.update_meta_infos (Com.Area.get_root area) path in
       let directory = Com.Path.get_directory path in
       let file = Com.Path.get_file path in
       let json =
         match directory, file with
         | Some d, Some f -> 
           let uploaded = Com.Uploaded.make ~area_id ~subdirs:(Srv.Directory.to_list_of_string d) ~file:f in
           Com.Uploaded.yojson_of_t uploaded  |> Yojson.Safe.to_string
         | _ -> ""
       in
       S.Response.make_raw ~code:201 json
       (*
       |> S.Response.set_header "Access-Control-Allow-Origin" "*"
       |> S.Response.set_header "Access-Control-Allow-Credentials" "true"
       |> S.Response.set_header "Access-Control-Max-Age" "1800"
       |> S.Response.set_header "Access-Control-Allow-Headers" "content-type"
       |> S.Response.set_header "Access-Control-Allow-Methods" "PUT, POST, GET, DELETE, PATCH, OPTIONS"
       |> S.Response.set_header "Access-Control-Allow-Headers" "X-Shupdofi-Data"
       *)
    );

  (* files of dir *)
  (*
  S.add_route_handler ~meth:`GET server
    S.Route.(exact "ls" @/ string @/ return)
    (fun _ _req -> (
         let l = Srv.File.ls "." in
         let json = Srv.File.yojson_of_collection l |> Yojson.Safe.to_string in
         S.Response.make_string (Ok json))
    );
    *)

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

         let () = prerr_endline id in
         let () = prerr_endline subdirs in

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

(*
  S.add_route_handler ~meth:`GET server
    S.Route.(exact "api" @/ exact "area" @/ exact "content" @/ string @/ return)
    (fun id _req -> (
         match id with
         | "" ->
           S.Response.make_raw ~code:404 "Not found"
         | _ ->
           let content = Srv.Area.get_content ~id ~subdirs:[] in
           S.Response.make_string (Ok (Com.Area_content.yojson_of_t content |> Yojson.Safe.to_string))
           |> S.Response.set_header "Content-Type" "text/json"
       )
    );
    *)


  (* run the server *)
  Printf.printf "listening on http://%s:%d\n%!" (S.addr server) (S.port server);
  match S.run server with
  | Ok () -> ()
  | Error e -> raise e
