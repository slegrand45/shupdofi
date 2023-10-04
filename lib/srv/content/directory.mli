module Com = Shupdofi_com

type absolute = Com.Directory.absolute Com.Directory.t
type relative = Com.Directory.relative Com.Directory.t

val make_from_list : string list -> relative
val to_list_of_string : relative -> string list
val concat_absolute : absolute -> relative -> absolute
val concat_relative : relative -> relative -> relative
val is_usable : absolute -> bool
val retrieve_mdatetime : (Com.Datetime.t option -> 'a -> 'a) -> 'a * Unix.LargeFile.stats option -> 'a * Unix.LargeFile.stats option
val read : absolute -> relative list * Com.File.t list
val next_if_exists : 'a Com.Directory.t -> Com.Directory.relative Com.Directory.t -> Com.Directory.relative Com.Directory.t
val mkdir : absolute -> string list -> relative option
val rename : absolute -> before:relative -> after:relative -> Unix.LargeFile.stats option
val delete : absolute -> relative -> unit
(*val tree : root:absolute -> subdir:relative -> dir:relative -> Com.Directory.relative Com.Directory.t list*)
(*val create_from_tree : paste_mode:Com.Path.paste -> tree:Com.Directory.relative Com.Directory.t list -> root:absolute -> subdir:relative ->
  ((Com.Directory.relative Com.Directory.t * Com.Directory.relative Com.Directory.t option), Com.Directory.relative Com.Directory.t) result list*)
val size : stop:int64 -> absolute -> int64
val absolute_subdirs : absolute -> relative list -> absolute list