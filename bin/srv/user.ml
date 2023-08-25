module Config = Shupdofi_srv_config
module Com = Shupdofi_com
module S = Tiny_httpd

let get config user =
  let name = Config.User.get_name user in
  let areas_rights =
    Config.Config.get_areas_accesses config
    |> List.filter_map
      (fun area -> 
         let area_id = Config.(Area_access.get_area area |> Area.get_area_id) in
         let actions = Auth.user_actions config user (Config.Area_access.get_area area) in
         match actions with
         | [] -> None
         | actions -> Some (area_id, actions))
  in
  let user = Com.User.make ~name ~areas_rights in
  let json = Com.User.yojson_of_t user |> Yojson.Safe.to_string in
  S.Response.make_raw ~code:200 json