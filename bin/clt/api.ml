open Js_browser
open Vdom

type 'msg Vdom.Cmd.t +=
  | Http_get of {url: string; payload: string; on_done: (int -> string -> 'msg)}
  | Http_post of {url: string; payload: string; on_done: (int -> string -> 'msg)}
  | Http_post_file of {url: string; file: File.t; on_done: (int -> string -> 'msg)}
  | Send of 'msg

let http_get (type msg) ~url ~payload (on_done : _ -> _ -> msg) : msg Vdom.Cmd.t =
  Http_get {url; payload; on_done}

let http_post (type msg) ~url ~payload (on_done : _ -> _ -> msg) : msg Vdom.Cmd.t =
  Http_post {url; payload; on_done}

let http_post_file (type msg) ~url ~file (on_done : _ -> _ -> msg) : msg Vdom.Cmd.t =
  Http_post_file {url; file; on_done}

let cmd_handler ctx = function
  | Http_get {url; payload; on_done} ->
    Http.run_http_get ~url ~payload ~on_done:(fun status response ->
        Vdom_blit.Cmd.send_msg ctx (on_done status response)) ();
    true
  | Http_post {url; payload; on_done} ->
    Http.run_http_post ~url ~payload ~on_done:(fun status response ->
        Vdom_blit.Cmd.send_msg ctx (on_done status response)) ();
    true
  | Http_post_file {url; file; on_done} ->
    Http.run_http_post_file ~url ~file:(File.t_to_js file) ~on_done:(fun status response ->
        Vdom_blit.Cmd.send_msg ctx (on_done status response)) ();
    true
  | Send msg ->
    Vdom_blit.Cmd.send_msg ctx msg;
    true
  | _ -> false

let send v = Send v
