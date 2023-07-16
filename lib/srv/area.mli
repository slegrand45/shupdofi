module Com = Shupdofi_com_com
module Msg = Shupdofi_com_msg

type t = Com.Area.t
type collection = t list

val get_all : unit -> collection
val get_content : id:string -> subdirs:string list -> Msg.Area_content.t