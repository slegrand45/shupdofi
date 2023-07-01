open Js_of_ocaml

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

let spinner_uploading doc =
  let div_spinner = Dom_html.createDiv doc in
  let () = div_spinner##setAttribute (Js.string "class") (Js.string "spinner-border spinner-border-sm ms-2") in
  let () = div_spinner##setAttribute (Js.string "role") (Js.string "status") in
  let spinner_span = Dom_html.createSpan doc in
  let () = spinner_span##setAttribute (Js.string "class") (Js.string "visually-hidden") in
  let text_spinner = Dom_html.document##createTextNode (Js.string "Uploading...") in
  let () = Dom.appendChild spinner_span text_spinner in
  let () = Dom.appendChild div_spinner spinner_span in
  div_spinner

let icon_ok doc =
  let div = Dom_html.createDiv doc in
  let svg = Dom_svg.createSvg Dom_svg.document in
  let () = svg##setAttribute (Js.string "class") (Js.string "ms-2") in
  let () = svg##setAttribute (Js.string "width") (Js.string "16") in
  let () = svg##setAttribute (Js.string "height") (Js.string "16") in
  let () = svg##setAttribute (Js.string "fill") (Js.string "currentColor") in
  let () = svg##setAttribute (Js.string "viewbox") (Js.string "0 0 16 16") in
  let path = Dom_svg.createPath Dom_svg.document in
  let () = path##setAttribute (Js.string "d") (Js.string "M12.736 3.97a.733.733 0 0 1 1.047 0c.286.289.29.756.01 1.05L7.88 12.01a.733.733 0 0 1-1.065.02L3.217 8.384a.757.757 0 0 1 0-1.06.733.733 0 0 1 1.047 0l3.052 3.093 5.4-6.425a.247.247 0 0 1 .02-.022Z") in
  let () = Dom.appendChild svg path in
  let () = Dom.appendChild div svg in
  div

let icon_ko doc =
  let div = Dom_html.createDiv doc in
  let svg = Dom_svg.createSvg Dom_svg.document in
  let () = svg##setAttribute (Js.string "class") (Js.string "ms-2") in
  let () = svg##setAttribute (Js.string "width") (Js.string "16") in
  let () = svg##setAttribute (Js.string "height") (Js.string "16") in
  let () = svg##setAttribute (Js.string "fill") (Js.string "currentColor") in
  let () = svg##setAttribute (Js.string "viewbox") (Js.string "0 0 16 16") in
  let path1 = Dom_svg.createPath Dom_svg.document in
  let () = path1##setAttribute (Js.string "d") (Js.string "M7.938 2.016A.13.13 0 0 1 8.002 2a.13.13 0 0 1 .063.016.146.146 0 0 1 .054.057l6.857 11.667c.036.06.035.124.002.183a.163.163 0 0 1-.054.06.116.116 0 0 1-.066.017H1.146a.115.115 0 0 1-.066-.017.163.163 0 0 1-.054-.06.176.176 0 0 1 .002-.183L7.884 2.073a.147.147 0 0 1 .054-.057zm1.044-.45a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566z") in
  let path2 = Dom_svg.createPath Dom_svg.document in
  let () = path2##setAttribute (Js.string "d") (Js.string "M7.002 12a1 1 0 1 1 2 0 1 1 0 0 1-2 0zM7.1 5.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995z") in
  let () = Dom.appendChild svg path1 in
  let () = Dom.appendChild svg path2 in
  let () = Dom.appendChild div svg in
  div

let html ~doc ~id ~msg =
  let div = Dom_html.createDiv doc in
  let () = div##setAttribute (Js.string "class") (Js.string "toast align-items-center text-bg-primary border-0") in
  let () = div##setAttribute (Js.string "data-bs-autohide") (Js.string "false") in
  let () = div##setAttribute (Js.string "id") (Js.string id) in
  let () = div##setAttribute (Js.string "role") (Js.string "alert") in
  let () = div##setAttribute (Js.string "aria-live") (Js.string "assertive") in
  let () = div##setAttribute (Js.string "aria-atomic") (Js.string "true") in
  let div_flex = Dom_html.createDiv doc in
  let () = div_flex##setAttribute (Js.string "class") (Js.string "d-flex align-items-center justify-content-between") in
  let close_button = Dom_html.createButton doc in
  let () = close_button##setAttribute (Js.string "class") (Js.string "btn-close btn-close-white me-2 m-auto") in
  let () = close_button##setAttribute (Js.string "type") (Js.string "button") in
  let () = close_button##setAttribute (Js.string "data-bs-dismiss") (Js.string "toast") in
  let () = close_button##setAttribute (Js.string "aria-label") (Js.string "Close") in
  let div_body = Dom_html.createDiv doc in
  let () = div_body##setAttribute (Js.string "class") (Js.string "toast-body") in
  let text_body = Dom_html.document##createTextNode (Js.string msg) in
  let div_spinner = spinner_uploading doc in
  let () = Dom.appendChild div div_flex in
  let () = Dom.appendChild div_flex div_spinner in
  let () = Dom.appendChild div_flex div_body in
  let () = Dom.appendChild div_body text_body in
  let () = Dom.appendChild div_flex close_button in
  div

let set_status_ok ~doc ~id ~delay =
  let div = Dom_html.getElementById id in
  let () = div##.classList##remove (Js.string "text-bg-primary") in
  let () = div##.classList##add (Js.string "text-bg-success") in
  let elt = Js.Opt.get (div##querySelector (Js.string ".spinner-border")) (fun () -> assert false) in
  elt##.outerHTML := (Js.string "");
  let elt = Js.Opt.get (div##querySelector (Js.string ".d-flex")) (fun () -> assert false) in
  Dom.insertBefore elt (icon_ok doc) (div##querySelector (Js.string ".toast-body"));
  let _ = Lwt.bind (Js_of_ocaml_lwt.Lwt_js.sleep delay) (fun () ->
      let elt = Js_browser.Document.get_element_by_id Js_browser.document id in
      let toast = Option.bind elt (fun e -> Some (getInstance e)) in
      Option.iter (fun e -> e##hide()) toast;
      Lwt.return ()) in
  ()

let set_status_ko ~doc ~id ~msg =
  let div = Dom_html.getElementById id in
  let () = div##.classList##remove (Js.string "text-bg-primary") in
  let () = div##.classList##add (Js.string "text-bg-danger") in
  let elt = Js.Opt.get (div##querySelector (Js.string ".spinner-border")) (fun () -> assert false) in
  elt##.outerHTML := (Js.string "");
  let elt = Js.Opt.get (div##querySelector (Js.string ".d-flex")) (fun () -> assert false) in
  Dom.insertBefore elt (icon_ko doc) (div##querySelector (Js.string ".toast-body"));
  let elt = Js.Opt.get (div##querySelector (Js.string ".toast-body")) (fun () -> assert false) in
  elt##.innerText := (Js.string msg)
