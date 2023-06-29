class type modal =
  object
    method dispose : unit -> unit Js_of_ocaml.Js.meth
    method show : unit -> unit Js_of_ocaml.Js.meth
    method hide : unit -> unit Js_of_ocaml.Js.meth
    method toggle : unit -> unit Js_of_ocaml.Js.meth
  end

val getInstance : Js_browser.Element.t -> modal Js_of_ocaml.Js.t
val getOrCreateInstance : Js_browser.Element.t -> modal Js_of_ocaml.Js.t
val show : unit -> unit
val hide : unit -> unit