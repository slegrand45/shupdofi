val run_http_get : url:string -> payload:string -> on_done:(int -> string -> unit) -> unit -> unit
val run_http_post : url:string -> payload:string -> on_done:(int -> string -> unit) -> unit -> unit
val run_http_post_file : url:string -> file:Ojs.t -> on_done:(int -> string -> unit) -> unit -> unit
val run_http_post_response_blob : url:string -> payload:string -> on_done:(int -> Ojs.t -> unit) -> unit -> unit
val run_http_delete : url:string -> payload:string -> on_done:(int -> string -> unit) -> unit -> unit