open Js_browser
open Vdom

type 'msg Vdom.Cmd.t +=
  | Http_get of {url: string; payload: string; on_done: (string -> 'msg)}
  | Http_put of {url: string; payload: string; on_done: (string -> 'msg)}
  | Http_put_file of {url: string; file: File.t; on_done: (int -> string -> 'msg)}
  | Send of 'msg

let http_get (type msg) ~url ~payload (on_done : _ -> msg) : msg Vdom.Cmd.t =
  Http_get {url; payload; on_done}

let http_put (type msg) ~url ~payload (on_done : _ -> msg) : msg Vdom.Cmd.t =
  Http_put {url; payload; on_done}

let http_put_file (type msg) ~url ~file (on_done : _ -> _ -> msg) : msg Vdom.Cmd.t =
  Http_put_file {url; file; on_done}

let cmd_handler ctx = function
  | Http_get {url; payload; on_done} ->
    Http.run_http_get ~url ~payload ~on_done:(fun s -> Vdom_blit.Cmd.send_msg ctx (on_done s)) ();
    true
  | Http_put {url; payload; on_done} ->
    Http.run_http_put ~url ~payload ~on_done:(fun s -> Vdom_blit.Cmd.send_msg ctx (on_done s)) ();
    true
  | Http_put_file {url; file; on_done} ->
    Http.run_http_put_file ~url ~file:(File.t_to_js file) ~on_done:(fun status response ->
        Vdom_blit.Cmd.send_msg ctx (on_done status response)) ();
    true
  | Send msg ->
    Vdom_blit.Cmd.send_msg ctx msg;
    true
  | _ -> false

let send v = Send v
