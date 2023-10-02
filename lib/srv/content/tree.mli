module Com = Shupdofi_com

type result_directory_ok
type result_directory_error
type result_file_ok
type result_file_error
type t

val selection_size : root:Directory.absolute -> subdir:Directory.relative
  -> dirs:Directory.relative list -> files:Shupdofi_com.File.t list -> int64

val selection_copy : from_root:Directory.absolute -> from_subdir:Directory.relative ->
  to_root:Directory.absolute -> to_subdir:Directory.relative ->
  dirs:'a Com.Directory.t list -> files:Com.File.t list ->
  paste_mode:Com.Path.paste -> t

val get_result_directories_ok : t -> result_directory_ok list
val get_result_directories_error : t -> result_directory_error list
val get_result_files_ok : t -> result_file_ok list
val get_result_files_error : t -> result_file_error list
val get_ok_from_dir_relative : result_directory_ok -> Com.Directory.relative Com.Directory.t
val get_ok_to_dir_relative : result_directory_ok -> Com.Directory.relative Com.Directory.t
val get_error_from_dir_relative : result_directory_error -> Com.Directory.relative Com.Directory.t
val get_error_to_dir_relative : result_directory_error -> Com.Directory.relative Com.Directory.t
val get_error_dir_msg : result_directory_error -> string
val get_ok_from_file_relative : result_file_ok -> Com.Directory.relative Com.Path.t
val get_ok_to_file_relative : result_file_ok -> Com.Directory.relative Com.Path.t
val get_error_from_file_relative : result_file_error -> Com.Directory.relative Com.Path.t
val get_error_to_file_relative : result_file_error -> Com.Directory.relative Com.Path.t
val get_error_file_msg : result_file_error -> string