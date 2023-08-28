type t

val empty : t
val to_string : t -> string
val file : area:Area.t -> subdirs:string list -> File.t -> t -> t
val directory : area:Area.t -> subdirs:string list -> Directory.relative Directory.t -> t -> t
val same_location : area:Area.t -> subdirs:string list -> t -> bool
val all : area:Area.t -> subdirs:string list -> directories:Directory.relative Directory.t list -> files:File.t list -> t -> t
val directory_is_selected : area:Area.t -> subdirs:string list -> directory:Directory.relative Directory.t -> t -> bool
val file_is_selected : area:Area.t -> subdirs:string list -> file:File.t -> t -> bool
val all_is_selected : area:Area.t -> subdirs:string list -> t -> bool
val count : t -> int