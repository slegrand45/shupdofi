val cmd_handler : 'a Vdom_blit.Cmd.ctx -> 'a Vdom.Cmd.t -> bool
val send : 'a -> 'a Vdom.Cmd.t
(* val get_all : Shupdofi_com.Page.t -> Shupdofi_com.Area.collection *)
val http_get : url:string -> payload:string -> (string -> 'a) -> 'a Vdom.Cmd.t
val http_post : url:string -> payload:string -> (int -> string -> 'a) -> 'a Vdom.Cmd.t
(*val http_put : url:string -> payload:string -> (string -> 'a) -> 'a Vdom.Cmd.t*)
val http_post_file : url:string -> file:Js_browser.File.t -> (int -> string -> 'a) -> 'a Vdom.Cmd.t