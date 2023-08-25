module S = Tiny_httpd
module Com = Shupdofi_com
module Config = Shupdofi_srv_config
module Content = Shupdofi_srv_content
module Msg_from_clt = Shupdofi_msg_srv_from_clt
module Msg_to_clt = Shupdofi_msg_srv_to_clt

let list config user =
  let areas = (Config.Config.get_areas config)
              |> List.filter (fun e -> Config.Area.get_root e |> Content.Directory.is_usable)
              |> List.filter (fun e -> Auth.user_has_at_least_one_right config user e)
              |> List.map Config.Area.get_area
  in
  S.Response.make_string (Ok (Com.Area.yojson_of_collection areas |> Yojson.Safe.to_string))
  |> S.Response.set_header "Content-Type" "text/json"

let content config user area_id subdirs =
  (* prerr_endline "** Headers:";
     S.Headers.pp Format.err_formatter (S.Request.headers _req) ;
     prerr_endline "** **"; *)
  match area_id with
  | "" ->
    S.Response.make_raw ~code:404 "Not found"
  | _ ->
    let area = List.find_opt (fun e -> Config.Area.get_area_id e = area_id) (Config.Config.get_areas config) in
    match area with
    | None -> S.Response.fail ~code:404 "Unknown area"
    | Some area ->
      match Auth.user_has_at_least_one_right config user area with
      | true -> (
          let subdirs = String.split_on_char '/' subdirs |> List.filter (fun e -> e <> "") in
          let content = Content.Area.get_content ~area ~subdirs in
          S.Response.make_string (Ok (Com.Area_content.yojson_of_t content |> Yojson.Safe.to_string))
          |> S.Response.set_header "Content-Type" "text/json"
        )
      | false -> S.Response.fail ~code:403 "Area access is not authorized"
