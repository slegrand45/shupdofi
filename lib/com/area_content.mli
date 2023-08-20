type t

val make : area:Area.t -> subdirs:string list -> directories:Directory.relative Directory.t list -> files:File.t list -> t
val to_string : t -> string
val get_area : t -> Area.t
val get_subdirs : t -> string list
val get_directories : t -> Directory.relative Directory.t list
val get_files : t -> File.t list
val set_area : Area.t -> t -> t
val set_subdirs : string list -> t -> t
val set_directories : Directory.relative Directory.t list -> t -> t
val set_files : File.t list -> t -> t
val add_uploaded : id:string -> subdirs:string list -> file:File.t -> t -> t
val add_new_directory : id:string -> subdirs:string list -> directory:Directory.relative Directory.t -> t -> t
val rename_directory : id:string -> subdirs:string list -> old_directory:Directory.relative Directory.t -> new_directory:Directory.relative Directory.t -> t -> t
val rename_file : id:string -> subdirs:string list -> old_file:File.t -> new_file:File.t -> t -> t
val remove_directory : id:string -> subdirs:string list -> dirname:string -> t -> t
val remove_file : id:string -> subdirs:string list -> filename:string -> t -> t
val sort : Sorting.t -> t -> t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
