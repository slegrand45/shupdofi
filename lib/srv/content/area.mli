module Com = Shupdofi_com
module Config = Shupdofi_srv_config

type t = Com.Area.t
type collection = t list

val get_all : Config.Config.t -> collection
val get_content : Config.Config.t -> id:string -> subdirs:string list -> Com.Area_content.t