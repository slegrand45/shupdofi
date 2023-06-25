class type toast =
  object
    method dispose : unit -> unit Js_of_ocaml.Js.meth
    method show : unit -> unit Js_of_ocaml.Js.meth
    method hide : unit -> unit Js_of_ocaml.Js.meth
  end

let getInstance (elt : Js_browser.Element.t) : toast Js_of_ocaml.Js.t =
  Js_of_ocaml.Js.Unsafe.fun_call (Js_of_ocaml.Js.Unsafe.js_expr "bootstrap.Toast.getInstance") [|Js_of_ocaml.Js.Unsafe.inject elt|]

let getOrCreateInstance (elt : Js_browser.Element.t) : toast Js_of_ocaml.Js.t =
  Js_of_ocaml.Js.Unsafe.fun_call (Js_of_ocaml.Js.Unsafe.js_expr "bootstrap.Toast.getOrCreateInstance") [|Js_of_ocaml.Js.Unsafe.inject elt|]
