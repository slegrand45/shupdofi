module Com = Shupdofi_com

type absolute = Com.Directory.absolute Com.Directory.t
type relative = Com.Directory.relative Com.Directory.t

val make_from_list : string list -> relative
val to_list_of_string : relative -> string list
val concat : absolute -> relative -> absolute
val read : absolute -> relative list * Com.File.t list
val mkdir : absolute -> string list -> relative option