module Com = Shupdofi_com

type t

val make : www_root:Com.Directory.t -> t
val get_www_root : t -> Com.Directory.t