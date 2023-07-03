let create_request ~verb ~url ~on_done () =
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

let run_http_get ~url ~payload ~on_done () =
  let r = create_request ~verb:"GET" ~url ~on_done () in
  Js_browser.XHR.send r (Ojs.string_to_js payload)

let run_http_post ~url ~payload ~on_done () =
  let r = create_request ~verb:"POST" ~url ~on_done () in
  Js_browser.XHR.send r (Ojs.string_to_js payload)

let run_http_post_file ~url ~file ~on_done () =
  let r = create_request ~verb:"POST" ~url ~on_done () in
  Js_browser.XHR.send r file