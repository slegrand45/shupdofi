module Config = Shupdofi_srv_config

val get_user_from_login : Config.Config.t -> string -> Config.User.t option