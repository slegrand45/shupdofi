module Com = Shupdofi_com

type t = Com.Directory.t

val make_from_list : string list -> t
val to_list_of_string : t -> string list
val concat : t -> t -> t
val read : t -> Com.Directory.t list * Com.File.t list
val mkdir : Com.Directory.t -> string list -> Com.Directory.t option