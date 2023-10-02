module Com = Shupdofi_com

type 'a t = 'a Com.Path.t

val to_string : 'a t -> string
val absolute_from_string : string -> Com.Directory.absolute t
val relative_from_string : string -> Com.Directory.relative t
val add_extension : string -> 'a t -> 'a t
val retrieve_stat : 'a t -> Unix.LargeFile.stats option
val usable : Unix.LargeFile.stats option -> bool
val mime : 'a t -> string
val next_if_exists : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> Com.Directory.relative t
val oc : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> (bytes -> int -> int -> unit) * (unit -> unit)
val update_meta_infos : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> Com.Directory.relative t
val rename : Com.Directory.absolute Com.Directory.t -> before:Com.Directory.relative t -> after:Com.Directory.relative t -> (Com.File.t * Com.File.t) option
val delete : Com.Directory.absolute Com.Directory.t -> Com.Directory.relative t -> unit
(*val tree : root:Com.Directory.absolute Com.Directory.t -> subdir:Com.Directory.relative Com.Directory.t -> dir:Com.Directory.relative Com.Directory.t -> Com.Directory.relative t list*)
(*val size_of_tree : tree:Com.Directory.relative t list -> root:Com.Directory.absolute Com.Directory.t -> subdir:Com.Directory.relative Com.Directory.t -> Int64.t
  val copy_from_tree : paste_mode:Com.Path.paste -> tree:Com.Directory.relative t list
  -> dir_created:(Com.Directory.relative Com.Directory.t * Com.Directory.relative Com.Directory.t option, Com.Directory.relative Com.Directory.t) result list
  -> from_root:Com.Directory.absolute Com.Directory.t -> from_subdir:Com.Directory.relative Com.Directory.t
  -> to_root:Com.Directory.absolute Com.Directory.t -> to_subdir:Com.Directory.relative Com.Directory.t
  -> ((Com.Directory.relative Com.Path.t * Com.Directory.relative Com.Path.t option), Com.Directory.relative Com.Path.t) result list*)