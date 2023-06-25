let run_http_get ~url ~payload ~on_done () =
  let open Js_browser.XHR in
  let r = create () in
  open_ r "GET" url;
  set_response_type r "text";
  set_onreadystatechange r
    (fun () ->
       match ready_state r with
       | Done -> on_done (response_text r)
       | _ ->
         ()
    );
  send r (Ojs.string_to_js payload)

let run_http_put ~url ~payload ~on_done () =
  let open Js_browser.XHR in
  let r = create () in
  open_ r "PUT" url;
  set_response_type r "text";
  set_with_credentials r true;
  (* set_request_header r "X-Shupdofi-Data" "mydata"; *)
  set_onreadystatechange r
    (fun () ->
       match ready_state r with
       | Done -> on_done (response_text r)
       | _ ->
         ()
    );
  send r (Ojs.string_to_js payload)


let run_http_put_file ~url ~file ~on_done () =
  let open Js_browser.XHR in
  let r = create () in
  open_ r "PUT" url;
  set_response_type r "text";
  set_with_credentials r true;
  (* set_request_header r "X-Shupdofi-Data" "mydata"; *)
  set_onreadystatechange r
    (fun () ->
       match ready_state r with
       | Done ->
         on_done (status r) (response_text r)
       | _ ->
         ()
    );
  send r file