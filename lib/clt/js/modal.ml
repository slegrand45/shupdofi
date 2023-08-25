class type modal =
  object
    method dispose : unit -> unit Js_of_ocaml.Js.meth
    method show : unit -> unit Js_of_ocaml.Js.meth
    method hide : unit -> unit Js_of_ocaml.Js.meth
    method toggle : unit -> unit Js_of_ocaml.Js.meth
  end

let getInstance (elt : Js_browser.Element.t) : modal Js_of_ocaml.Js.t =
  Js_of_ocaml.Js.Unsafe.fun_call (Js_of_ocaml.Js.Unsafe.js_expr "bootstrap.Modal.getInstance") [|Js_of_ocaml.Js.Unsafe.inject elt|]

let getOrCreateInstance (elt : Js_browser.Element.t) : modal Js_of_ocaml.Js.t =
  Js_of_ocaml.Js.Unsafe.fun_call (Js_of_ocaml.Js.Unsafe.js_expr "bootstrap.Modal.getOrCreateInstance") [|Js_of_ocaml.Js.Unsafe.inject elt|]

let show () =
  let elt = Js_browser.(Document.get_element_by_id document "modal-container") in
  let modal = Option.bind elt (fun e -> Some (getOrCreateInstance e)) in
  Option.iter (fun e -> e##show()) modal

let hide () =
  let elt = Js_browser.(Document.get_element_by_id document "modal-container") in
  let modal = Option.bind elt (fun e -> Some (getOrCreateInstance e)) in
  Option.iter (fun e -> e##hide()) modal
