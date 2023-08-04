module S = Tiny_httpd
module Com = Shupdofi_com
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt

let list config _req =
  (* the root value must not (and doesn't need to) be set.

     TODO: return root only if user have access right
      (* ~root:(Com.Directory.make_absolute ~name:"..." ()) *)
  *)
  let areas = (Config.Config.get_areas config)
              |> List.filter (fun e -> Com.Area.get_root e |> Content.Directory.is_usable)
              |> List.map (Com.Area.set_root (Com.Directory.make_absolute ~name:"" ()))
  in
  S.Response.make_string (Ok (Com.Area.yojson_of_collection areas |> Yojson.Safe.to_string))
  |> S.Response.set_header "Content-Type" "text/json"

let content config id subdirs _req =
  (* prerr_endline "** Headers:";
     S.Headers.pp Format.err_formatter (S.Request.headers _req) ;
     prerr_endline "** **"; *)
  match id with
  | "" ->
    S.Response.make_raw ~code:404 "Not found"
  | _ ->
    let subdirs = String.split_on_char '/' subdirs |> List.filter (fun e -> e <> "") in
    let content = Content.Area.get_content config ~id ~subdirs in
    S.Response.make_string (Ok (Com.Area_content.yojson_of_t content |> Yojson.Safe.to_string))
    |> S.Response.set_header "Content-Type" "text/json"
