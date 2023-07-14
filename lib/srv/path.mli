module Com = Shupdofi_com

type 'a t = 'a Com.Path.t

val to_string : 'a t -> string
val absolute_from_string : string -> Com.Directory.absolute t
val relative_from_string : string -> Com.Directory.relative t
val add_extension : string -> 'a t -> 'a t
val retrieve_stat : 'a t -> Unix.LargeFile.stats option
val usable : Unix.LargeFile.stats option -> bool
val mime : 'a t -> string
val oc : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> (bytes -> int -> int -> unit) * (unit -> unit)
val update_meta_infos : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> Com.Directory.relative t
val delete : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> unit