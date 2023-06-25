open Js_browser
open Js_of_ocaml

val html : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> Js_of_ocaml.Dom_html.divElement Js_of_ocaml.Js.t
val set_status_ok : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> delay:float -> unit
val set_status_ko : doc:Js_of_ocaml.Dom_html.document Js_of_ocaml.Js.t -> id:string -> msg:string -> unit
