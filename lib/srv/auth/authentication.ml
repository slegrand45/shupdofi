module Config = Shupdofi_srv_config

let get_user_from_login config login =
  let open Config in
  Config.get_users config
  |> List.find_opt (fun e -> User.get_login e = login) 