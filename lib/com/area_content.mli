type t

val make : id:string -> subdirs:string list -> directories:Directory.t list -> files:File.t list -> t
val get_id : t -> string
val get_subdirs : t -> string list
val get_directories : t -> Directory.t list
val get_files : t -> File.t list
val set_id : string -> t -> t
val set_subdirs : string list -> t -> t
val add_uploaded : Uploaded.t -> t -> t
val add_new_directory : New_directory_created.t -> t -> t
val sort : t -> t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
