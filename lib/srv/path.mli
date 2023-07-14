module Com = Shupdofi_com

type t = Com.Path.t

val to_string : t -> string
val from_string : string -> t
val add_extension : string -> t -> t
val retrieve_stat : t -> Unix.LargeFile.stats option
val usable : Unix.LargeFile.stats option -> bool
val mime : t -> string
val oc : Com.Directory.t -> t -> (bytes -> int -> int -> unit) * (unit -> unit)
val update_meta_infos : Com.Directory.t -> t -> t
val delete : Com.Directory.t -> t -> unit