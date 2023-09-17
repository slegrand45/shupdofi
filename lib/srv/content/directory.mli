module Com = Shupdofi_com

type absolute = Com.Directory.absolute Com.Directory.t
type relative = Com.Directory.relative Com.Directory.t

val make_from_list : string list -> relative
val to_list_of_string : relative -> string list
val concat : absolute -> relative -> absolute
val is_usable : absolute -> bool
val read : absolute -> relative list * Com.File.t list
val mkdir : absolute -> string list -> relative option
val rename : absolute -> before:relative -> after:relative -> Unix.LargeFile.stats option
val delete : absolute -> relative -> unit
val tree : root:absolute -> subdir:relative -> dir:relative -> Com.Directory.relative Com.Directory.t list
val create_from_tree : tree:Com.Directory.relative Com.Directory.t list -> root:absolute -> subdir:relative ->
  ((Com.Directory.relative Com.Directory.t * Com.Directory.relative Com.Directory.t option), Com.Directory.relative Com.Directory.t) result list
val size : stop:int64 -> absolute -> int64