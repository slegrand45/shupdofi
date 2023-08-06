module Com = Shupdofi_com

type t

val make : area:Com.Area.t -> root:Com.Directory.absolute Com.Directory.t -> quota:(string * Com.Size.t option) -> t
val to_string : t -> string
val to_toml : t -> string
val get_area : t -> Com.Area.t
val get_area_id : t -> string
val get_root : t -> Com.Directory.absolute Com.Directory.t
val get_quota : t -> (string * Com.Size.t option)