module Authentication = Shupdofi_srv_auth.Authentication
module Authorization = Shupdofi_srv_auth.Authorization
module Config = Shupdofi_srv_config
module S = Tiny_httpd

let get_login config req =
  let authentications = Config.Config.get_authentications config in
  let find_login login meth =
    match login with
    | Some _ as v -> v
    | None -> match meth with
      | Config.Authentication.Http_header v -> (
          let header = Config.Authentication.Http_header.get_header_login v in
          S.Headers.get header (S.Request.headers req)
        )
  in
  List.fold_left find_login None authentications

let get_user config req =
  match get_login config req with
  | Some login -> Authentication.get_user_from_login config login
  | _ -> None

let user_authorized config req user area action =
  Authorization.user_authorized_to config user action (Config.Area.get_area area)

let user_has_at_least_one_right config req user area =
  Authorization.user_has_at_least_one_right config user (Config.Area.get_area area)

let user_actions config user area =
  Authorization.user_actions config user (Config.Area.get_area area)