module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Config = Shupdofi_srv_config.Config
module Content = Shupdofi_srv_content

(* cat bombardier-linux-amd64 | curl -vvvv -X PUT --data-binary @- http://127.0.0.1:8080/api/upload/xxx *)

let () =
  let www_root =
    Com.Directory.make_absolute ~name:"/home/slegrand45/depots-git/perso/shupdofi/www/" ();
  in
  let config = Config.make ~www_root in
  let www_root = Config.get_www_root config in
  let server = S.create () in

  let accept_gzip (req:_ S.Request.t) =
    match
      S.Request.get_header req "Accept-Encoding"
    with
    | Some s -> List.mem "gzip" @@ String.split_on_char ',' (String.trim s)
    | None -> false
  in

  let gzip_path_if_exists subdir path _req =
    let subdir = Com.Directory.make_relative ~name:subdir () in
    let path = Com.Path.make_absolute (Content.Directory.concat www_root subdir)
        (Com.File.make ~name:(Filename.basename path) ()) in
    let path_gzip = Content.Path.add_extension "gz" path in
    if (accept_gzip _req) && (Content.Path.(retrieve_stat path_gzip |> usable)) then
      (path_gzip, fun r -> S.Response.set_header "Content-Encoding" "gzip" r)
    else
      (path, fun r -> r)
  in

  S.set_top_handler 
    server
    (fun _req ->
       let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
           (Com.File.make ~name:"index.html" ()) in
       let ch = In_channel.open_bin (Content.Path.to_string path) in
       let stream = Tiny_httpd_stream.of_chan_close_noerr ch in
       S.Response.make_raw_stream ~code:S.Response_code.ok stream
       |> S.Response.set_header "Content-Type" "text/html"
    );

  (* static files *)
  S.add_route_handler ~meth:`GET server
    S.Route.(exact "www" @/ string_urlencoded @/ return)
    (fun path _req ->
       let subdir = Com.Directory.make_relative ~name:(Filename.dirname path) () in
       let path = Com.Path.make_absolute (Content.Directory.concat www_root subdir)
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
    (fun _req -> (
         let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
             (Com.File.make ~name:"favicon.ico" ()) in
         S.Response.make_string (Ok (In_channel.with_open_bin (Content.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "image/vnd.microsoft.icon"
       )
    );

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "robots.txt" @/ return)
    (fun _req -> (
         let path = Com.Path.make_absolute (Com.Directory.make_absolute ~name:(Com.Directory.get_name www_root) ())
             (Com.File.make ~name:"robots.txt" ()) in
         S.Response.make_string (Ok (In_channel.with_open_bin (Content.Path.to_string path) In_channel.input_all))
         |> S.Response.set_header "Content-Type" "text/plain"
       )
    );

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "file" @/ string_urlencoded @/ rest_of_path_urlencoded)
    File.upload;

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "file" @/ exact "rename" @/ return)
    File.rename;

  S.add_route_handler_stream ~meth:`GET server
    S.Route.(exact "api" @/ exact "file" @/ string_urlencoded @/ rest_of_path_urlencoded)
    File.download;

  S.add_route_handler_stream ~meth:`DELETE server
    S.Route.(exact "api" @/ exact "file" @/ return)
    File.delete;

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "directory" @/ exact "rename" @/ return)
    Directory.rename;

  S.add_route_handler_stream ~meth:`GET server
    S.Route.(exact "api" @/ exact "directory" @/ string_urlencoded @/ rest_of_path_urlencoded)
    Directory.archive;

  S.add_route_handler_stream ~meth:`POST server
    S.Route.(exact "api" @/ exact "directory" @/ return)
    Directory.create;

  S.add_route_handler_stream ~meth:`DELETE server
    S.Route.(exact "api" @/ exact "directory" @/ return)
    Directory.delete;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact_path "api/areas" return)
    Area.list;

  S.add_route_handler ~meth:`GET server
    S.Route.(exact "api" @/ exact "area" @/ exact "content" @/ string_urlencoded @/ rest_of_path_urlencoded)
    Area.content;

  (* run the server *)
  Printf.printf "listening on http://%s:%d\n%!" (S.addr server) (S.port server);
  match S.run server with
  | Ok () -> ()
  | Error e -> raise e
