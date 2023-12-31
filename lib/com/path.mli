type 'a t

type paste = Paste_ignore | Paste_overwrite | Paste_rename

type copy_move = Copy | Move

val make_absolute : Directory.absolute Directory.t -> File.t -> Directory.absolute t
val make_relative : Directory.relative Directory.t -> File.t -> Directory.relative t
val is_defined : 'a t -> bool
val get_directory : 'a t -> 'a Directory.t option
val get_file : 'a t -> File.t option
val set_directory : 'a Directory.t -> 'a t -> 'a t
val set_file : File.t -> 'a t -> 'a t

val copy_move_of_yojson : Yojson.Safe.t -> copy_move
val yojson_of_copy_move : copy_move -> Yojson.Safe.t

val paste_of_yojson : Yojson.Safe.t -> paste
val yojson_of_paste : paste -> Yojson.Safe.t

val t_of_yojson : (Yojson.Safe.t -> 'a) -> Yojson.Safe.t -> 'a t
val yojson_of_t : ('a -> Yojson.Safe.t) -> 'a t -> Yojson.Safe.t
