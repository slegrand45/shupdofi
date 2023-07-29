module Com = Shupdofi_com

type t = Com.Area.t
type collection = t list

val get_all : unit -> collection
val get_content : id:string -> subdirs:string list -> Com.Area_content.t