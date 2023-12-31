module Com = Shupdofi_com
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module S = Tiny_httpd

let start_server config =
  let www_root = Config.Config.get_server config |> Config.Server.get_www_root in
  let listen_address = Config.Config.get_server config |> Config.Server.get_listen_address in
  let listen_port = Config.Config.get_server config |> Config.Server.get_listen_port in
  let server = S.create ~addr:listen_address ~port:listen_port () in

  let gzip_path_if_exists subdir path _req =
    let subdir = Com.Directory.make_relative ~name:subdir () in
    let path = Com.Path.make_absolute (Content.Directory.concat_absolute www_root subdir)
        (Com.File.make ~name:(Filename.basename path) ()) in
    let path_gzip = Content.Path.add_extension "gz" path in
    if (Response.can_return_gzip _req) && (Content.Path.(retrieve_stat path_gzip |> usable)) then
      (path_gzip, fun r -> S.Response.set_header "Content-Encoding" "gzip" r)
    else
      (path, fun r -> r)
  in

  let exact_one_static_root_file filename mime _req =
    let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
        (Com.File.make ~name:filename ()) in
    S.Response.make_string (Ok (In_channel.with_open_bin (Content.Path.to_string path) In_channel.input_all))
    |> S.Response.set_header "Content-Type" mime
  in

  S.set_top_handler 
    server
    (fun _req ->
       let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
           (Com.File.make ~name:"index.html" ()) in
       let regexp = Str.regexp_string "${NONCE}" in
       let nonce =
         Random.self_init ();
         String.init 32 (fun _ -> Char.chr ((Random.int 26) + 65))
       in
       let html =
         In_channel.with_open_bin (Content.Path.to_string path) In_channel.input_all
         |> Str.global_replace regexp nonce
       in
       let csp = Printf.sprintf "script-src 'nonce-%s' 'strict-dynamic' https: 'unsafe-inline'; object-src 'none'; base-uri 'none'; require-trusted-types-for 'script';" nonce in
       S.Response.make_raw ~code:S.Response_code.ok html
       |> S.Response.set_header "Content-Type" "text/html"
       |> S.Response.set_header "Content-Security-Policy" csp
    );

  (* static files *)
  S.add_route_handler ~meth:`GET server
    S.Route.(exact "www" @/ string_urlencoded @/ return)
    (fun path _req ->
       let subdir = Com.Directory.make_relative ~name:(Filename.dirname path) () in
       let path = Com.Path.make_absolute (Content.Directory.concat_absolute www_root subdir)
           (Com.File.make ~name:(Filename.basename path) ()) in
       let ch = In_channel.open_bin (Content.Path.to_string path) in
       let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
       S.Response.make_raw_stream ~code:S.Response_code.ok stream
       |> S.Response.set_header "Content-Type" (Content.Path.mime path)
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "css" @/ string_urlencoded @/ return)
    (fun path _req -> (
         let (path, f_header) = gzip_path_if_exists "css" path _req in
         S.Response.make_string (Ok (In_channel.with_open_bin (Content.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/css"
         |> f_header
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "js" @/ string_urlencoded @/ return)
    (fun path _req -> (
         let (path, f_header) = gzip_path_if_exists "js" path _req in
         S.Response.make_string (Ok (In_channel.with_open_bin (Content.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/javascript"
         |> f_header
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "favicon.ico" @/ return)
    (exact_one_static_root_file "favicon.ico" "image/vnd.microsoft.icon")
  ;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "favicon.svg" @/ return)
    (exact_one_static_root_file "favicon.svg" "image/svg+xml")
  ;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "apple-touch-icon.png" @/ return)
    (exact_one_static_root_file "apple-touch-icon.png" "image/png")
  ;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "android-chrome-192x192.png" @/ return)
    (exact_one_static_root_file "android-chrome-192x192.png" "image/png")
  ;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "android-chrome-512x512.png" @/ return)
    (exact_one_static_root_file "android-chrome-512x512.png" "image/png")
  ;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "site.webmanifest" @/ return)
    (exact_one_static_root_file "site.webmanifest" "application/manifest+json")
  ;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "robots.txt" @/ return)
    (exact_one_static_root_file "robots.txt" "text/plain")
  ;

  let fail_user_unknown = (fun () -> S.Response.fail ~code:403 "User unknown") in

  (* API *)
  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "file" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun area path req -> Auth.get_user config req
                          |> Option.fold ~none:(fail_user_unknown())
                            ~some:(fun user -> File.upload config user area path req));

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "file" @/ exact "rename" @/ return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> File.rename config user req));

  S.add_route_handler_stream ~meth:`GET server
    S.Route.(exact "api" @/ exact "file" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun area_id path req -> Auth.get_user config req
                             |> Option.fold ~none:(fail_user_unknown())
                               ~some:(fun user -> File.download config user area_id path));

  S.add_route_handler_stream ~meth:`DELETE server
    S.Route.(exact "api" @/ exact "file" @/ return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> File.delete config user req));

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "directory" @/ exact "rename" @/ return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Directory.rename config user req));

  S.add_route_handler_stream ~meth:`GET server
    S.Route.(exact "api" @/ exact "directory" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun area_id path req -> Auth.get_user config req
                             |> Option.fold ~none:(fail_user_unknown())
                               ~some:(fun user -> Directory.archive config user area_id path));

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "directory" @/ return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Directory.create config user req));

  S.add_route_handler_stream ~meth:`DELETE server
    S.Route.(exact "api" @/ exact "directory" @/ return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Directory.delete config user req));

  S.add_route_handler ~meth:`GET server
    S.Route.(exact_path "api/areas" return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Area.list config user));

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "api" @/ exact "area" @/ exact "content" @/ string_urlencoded @/ rest_of_path_urlencoded)
    (fun area_id subdirs req -> Auth.get_user config req
                                |> Option.fold ~none:(fail_user_unknown())
                                  ~some:(fun user -> Area.content config user req area_id subdirs));

  S.add_route_handler ~meth:`GET server
    S.Route.(exact_path "api/user" return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> User.get config user req));

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact_path "api/selection/download" return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Selection.archive config user req));

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact_path "api/selection/copy" return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Selection.copy config user req));

  S.add_route_handler_stream ~meth:`DELETE server
    S.Route.(exact_path "api/selection" return)
    (fun req -> Auth.get_user config req
                |> Option.fold ~none:(fail_user_unknown())
                  ~some:(fun user -> Selection.delete config user req));

  match S.run server with
  | Ok () -> 
    Printf.printf "Start shupdofi server, listening on http://%s:%d\n%!" (S.addr server) (S.port server);
  | Error e -> 
    prerr_endline ("Unable to start server: " ^ (Printexc.to_string e))
;;

let usage_msg = Sys.executable_name ^ " -c <configuration file> [-t] " in
let config_file = ref "" in
let config_test = ref false in
let speclist =
  [
    ("-c", Arg.Set_string config_file, "Configuration file");
    ("-t", Arg.Set config_test, "Do not start the server, just test the configuration file")
  ]
in
let () = Arg.parse speclist (fun _ -> ()) usage_msg in
match ! config_file with
| "" -> prerr_endline "Error: please specify a configuration file with the -c option"
| _ ->
  let config = Config.Config.from_toml_file !config_file in
  match config with
  | Ok config -> (
      if (not !config_test) then
        start_server config;
    )
  | Error err ->
    prerr_endline ("Error in configuration file: " ^ err);
    exit 1;
