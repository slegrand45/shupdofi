module Com = Shupdofi_com_com

type t

val make : id:string -> subdirs:string list -> directories:Com.Directory.relative Com.Directory.t list -> files:Com.File.t list -> t
val get_id : t -> string
val get_subdirs : t -> string list
val get_directories : t -> Com.Directory.relative Com.Directory.t list
val get_files : t -> Com.File.t list
val set_id : string -> t -> t
val set_subdirs : string list -> t -> t
val add_uploaded : Uploaded.t -> t -> t
val add_new_directory : New_directory_created.t -> t -> t
val rename_file : File_renamed.t -> t -> t
val remove_file : id:string -> subdirs:string list -> filename:string -> t -> t
val sort : t -> t
val t_of_yojson : Yojson.Safe.t -> t
val yojson_of_t : t -> Yojson.Safe.t
