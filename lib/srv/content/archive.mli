module Com = Shupdofi_com

val create_archive_of_directory : archive:Com.Directory.absolute Com.Path.t -> root:Com.Directory.absolute Com.Directory.t -> subdir:Com.Directory.relative Com.Directory.t -> unit
val create_archive_of_names : archive:Com.Directory.absolute Com.Path.t -> root:Com.Directory.absolute Com.Directory.t -> subdir:Com.Directory.relative Com.Directory.t -> dirnames:string list -> filenames:string list -> unit