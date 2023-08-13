module Com = Shupdofi_com
module Config = Shupdofi_srv_config

val user_authorized_to : Config.Config.t -> Config.User.t -> Config.Area_access.Action.t -> Com.Area.t -> bool
val user_has_at_least_one_right : Config.Config.t -> Config.User.t -> Com.Area.t -> bool