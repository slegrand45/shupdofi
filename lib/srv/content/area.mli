module Com = Shupdofi_com
module Config = Shupdofi_srv_config

type t = Com.Area.t
type collection = t list

val get_content : Config.Config.t -> area:Config.Area.t -> subdirs:string list -> Com.Area_content.t