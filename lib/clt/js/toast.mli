open Js_browser

class type toast =
  object
    method dispose : unit -> unit Js_of_ocaml.Js.meth
    method show : unit -> unit Js_of_ocaml.Js.meth
    method hide : unit -> unit Js_of_ocaml.Js.meth
  end

val getInstance : Js_browser.Element.t -> toast Js_of_ocaml.Js.t
val getOrCreateInstance : Js_browser.Element.t -> toast Js_of_ocaml.Js.t

val html : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> Js_of_ocaml.Dom_html.divElement Js_of_ocaml.Js.t
val set_status_ok : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> delay:float -> unit
val set_status_ko : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> unit
val append_from_list : l:'a list -> prefix_id:string -> fun_msg:('a -> string) -> fun_cmd:(string -> 'a -> 'b) -> 'b list
val show : document:Document.t -> toast_id:string -> unit
val clean_hiddens : document:Document.t -> unit