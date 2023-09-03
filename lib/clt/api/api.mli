val cmd_handler : 'a Vdom_blit.Cmd.ctx -> 'a Vdom.Cmd.t -> bool
val send : 'a -> 'a Vdom.Cmd.t
val http_get : url:string -> payload:string -> (int -> string -> 'a) -> 'a Vdom.Cmd.t
val http_post : url:string -> payload:string -> (int -> string -> 'a) -> 'a Vdom.Cmd.t
val http_post_file : url:string -> file:Js_browser.File.t -> (int -> string -> 'a) -> 'a Vdom.Cmd.t
val http_post_response_blob : url:string -> payload:string -> (int -> Ojs.t -> 'a) -> 'a Vdom.Cmd.t
val http_delete : url:string -> payload:string -> (int -> string -> 'a) -> 'a Vdom.Cmd.t