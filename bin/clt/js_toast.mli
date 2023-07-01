open Js_browser
open Js_of_ocaml

class type toast =
  object
    method dispose : unit -> unit Js_of_ocaml.Js.meth
    method show : unit -> unit Js_of_ocaml.Js.meth
    method hide : unit -> unit Js_of_ocaml.Js.meth
  end

val getInstance : Js_browser.Element.t -> toast Js_of_ocaml.Js.t
val getOrCreateInstance : Js_browser.Element.t -> toast Js_of_ocaml.Js.t

val html : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> Js_of_ocaml.Dom_html.divElement Js_of_ocaml.Js.t
val set_status_ok : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> delay:float -> unit
val set_status_ko : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> unit
