class type toast =
  object
    method dispose : unit -> unit Js_of_ocaml.Js.meth
    method show : unit -> unit Js_of_ocaml.Js.meth
    method hide : unit -> unit Js_of_ocaml.Js.meth
  end

val getInstance : Js_browser.Element.t -> toast Js_of_ocaml.Js.t
val getOrCreateInstance : Js_browser.Element.t -> toast Js_of_ocaml.Js.t
