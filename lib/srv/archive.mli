module Com = Shupdofi_com

val create_archive_of_directory : archive:Com.Directory.absolute Com.Path.t -> root:Com.Directory.absolute Com.Directory.t -> subdir:Com.Directory.relative Com.Directory.t -> unit