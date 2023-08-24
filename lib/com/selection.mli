type t

val empty : t list
val to_string : t list -> string
val file : area:Area.t -> subdirs:string list -> File.t -> t list -> t list
val directory : area:Area.t -> subdirs:string list -> Directory.relative Directory.t -> t list -> t list
val all : area:Area.t -> subdirs:string list -> directories:Directory.relative Directory.t list -> files:File.t list -> t list -> t list
val directory_is_selected : area:Area.t -> subdirs:string list -> directory:Directory.relative Directory.t -> t list -> bool
val file_is_selected : area:Area.t -> subdirs:string list -> file:File.t -> t list -> bool
val all_is_selected : area:Area.t -> subdirs:string list -> t list -> bool
val count : t list -> int
val clear : area:Area.t -> subdirs:string list -> t list -> t list