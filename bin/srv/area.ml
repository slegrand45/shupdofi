module S = Tiny_httpd
module Com = Shupdofi_com
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt
module Content = Shupdofi_srv_content

let list _req =
  let areas = Content.Area.get_all () in
  S.Response.make_string (Ok (Com.Area.yojson_of_collection areas |> Yojson.Safe.to_string))
  |> S.Response.set_header "Content-Type" "text/json"

let content id subdirs _req =
  (* prerr_endline "** Headers:";
     S.Headers.pp Format.err_formatter (S.Request.headers _req) ;
     prerr_endline "** **"; *)
  match id with
  | "" ->
    S.Response.make_raw ~code:404 "Not found"
  | _ ->
    let subdirs = String.split_on_char '/' subdirs |> List.filter (fun e -> e <> "") in
    let content = Content.Area.get_content ~id ~subdirs in
    S.Response.make_string (Ok (Com.Area_content.yojson_of_t content |> Yojson.Safe.to_string))
    |> S.Response.set_header "Content-Type" "text/json"
