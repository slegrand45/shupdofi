let create_request_response_text ~verb ~url ~on_done () =
  let open Js_browser.XHR in
  let r = create () in
  open_ r verb url;
  set_response_type r "text";
  set_with_credentials r true;
  set_onreadystatechange r
    (fun () ->
       match ready_state r with
       | Done -> on_done (status r) (response_text r)
       | _ ->
         ()
    );
  r

let create_request_response_blob ~verb ~url ~on_done () =
  let open Js_browser.XHR in
  let r = create () in
  open_ r verb url;
  set_response_type r "blob";
  set_with_credentials r true;
  set_onreadystatechange r
    (fun () ->
       match ready_state r with
       | Done -> on_done (status r) (response r)
       | _ ->
         ()
    );
  r

let run_http_get ~url ~payload ~on_done () =
  let r = create_request_response_text ~verb:"GET" ~url ~on_done () in
  Js_browser.XHR.send r (Ojs.string_to_js payload)

let run_http_post ~url ~payload ~on_done () =
  let r = create_request_response_text ~verb:"POST" ~url ~on_done () in
  Js_browser.XHR.send r (Ojs.string_to_js payload)

let run_http_post_file ~url ~file ~on_done () =
  let r = create_request_response_text ~verb:"POST" ~url ~on_done () in
  Js_browser.XHR.send r file

let run_http_post_response_blob ~url ~payload ~on_done () =
  let r = create_request_response_blob ~verb:"POST" ~url ~on_done () in
  Js_browser.XHR.send r (Ojs.string_to_js payload)

let run_http_delete ~url ~payload ~on_done () =
  let r = create_request_response_text ~verb:"DELETE" ~url ~on_done () in
  Js_browser.XHR.send r (Ojs.string_to_js payload)