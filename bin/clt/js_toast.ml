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
  let () = svg##setAttribute (Js.string "width") (Js.string "24") in
  let () = svg##setAttribute (Js.string "height") (Js.string "24") in
  let () = svg##setAttribute (Js.string "fill") (Js.string "currentColor") in
  let () = svg##setAttribute (Js.string "viewbox") (Js.string "0 0 24 24") in
  let path1 = Dom_svg.createPath Dom_svg.document in
  let () = path1##setAttribute (Js.string "fill") (Js.string "none") in
  let () = path1##setAttribute (Js.string "d") (Js.string "M0 0h24v24H0V0z") in
  let path2 = Dom_svg.createPath Dom_svg.document in
  let () = path2##setAttribute (Js.string "d") (Js.string "M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z") in
  let () = Dom.appendChild svg path1 in
  let () = Dom.appendChild svg path2 in
  let () = Dom.appendChild div svg in
  div

let icon_ko doc =
  let div = Dom_html.createDiv doc in
  let svg = Dom_svg.createSvg Dom_svg.document in
  let () = svg##setAttribute (Js.string "class") (Js.string "ms-2") in
  let () = svg##setAttribute (Js.string "width") (Js.string "24") in
  let () = svg##setAttribute (Js.string "height") (Js.string "24") in
  let () = svg##setAttribute (Js.string "fill") (Js.string "currentColor") in
  let () = svg##setAttribute (Js.string "viewbox") (Js.string "0 0 24 24") in
  let path = Dom_svg.createPath Dom_svg.document in
  let () = path##setAttribute (Js.string "d") (Js.string "M12 5.99L19.53 19H4.47L12 5.99M12 2L1 21h22L12 2zm1 14h-2v2h2v-2zm0-6h-2v4h2v-4z") in
  let () = Dom.appendChild svg path in
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

let append_from_list ~l ~prefix_id ~fun_msg ~fun_cmd =
  let () = Random.self_init () in
  let document = Dom_html.window##.document in
  let container = Js.Opt.get (document##getElementById (Js.string "toast-container")) (fun () -> assert false) in
  let (elts, c) = List.fold_left (
      fun (elts, c) e ->
        let now = new%js Js.date_now in
        let iso = Js.to_string now##toISOString in
        let rnd = Random.int 1_073_741_820 in
        let toast_id = prefix_id ^ "-toast-" ^ iso ^ "-" ^ (Int.to_string rnd) in
        let name = fun_msg e in
        let elts = (html ~doc:Dom_html.document ~id:toast_id ~msg:name)::elts in
        let c = (fun_cmd toast_id e) :: c in
        (elts, c)
    ) ([], []) l
  in
  List.iter (fun e -> Dom.appendChild container e) elts;
  c

let show ~document ~toast_id =
  let elt = Js_browser.Document.get_element_by_id document toast_id in
  let toast = Option.bind elt (fun e -> Some (getOrCreateInstance e)) in
  Option.iter (fun e -> e##show()) toast

let clean_hiddens ~document =
  let container = Dom_html.getElementById "toast-container" in
  let elements = container##querySelectorAll (Js.string ".toast.hide") in
  elements |> Dom.list_of_nodeList |> List.iter (fun e ->
      let id = Js.Opt.get (e##getAttribute (Js.string "id")) (fun () -> assert false) in
      let elt = Js_browser.Document.get_element_by_id document (Js.to_string id) in
      let toast = Option.bind elt (fun e -> Some (getInstance e)) in
      Option.iter (fun e -> e##dispose()) toast;
      e##.outerHTML := (Js.string "")
    )