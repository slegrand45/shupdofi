module Com = Shupdofi_com

type t

val make : www_root:Com.Directory.absolute Com.Directory.t -> listen_address:string -> listen_port:int -> t
val to_toml : t -> string
val get_www_root : t -> Com.Directory.absolute Com.Directory.t
val get_listen_address : t -> string
val get_listen_port : t -> int