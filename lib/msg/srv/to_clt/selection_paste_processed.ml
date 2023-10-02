open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type result_directory_ok = {
  from_dir : Com.Directory.relative Com.Directory.t;
  to_dir : Com.Directory.relative Com.Directory.t;
}
[@@deriving yojson]

type result_directory_error = {
  from_dir : Com.Directory.relative Com.Directory.t;
  to_dir : Com.Directory.relative Com.Directory.t;
  msg : string;
}
[@@deriving yojson]

type result_file_ok = {
  from_file : Com.Directory.relative Com.Path.t;
  to_file : Com.Directory.relative Com.Path.t;
}
[@@deriving yojson]

type result_file_error = {
  from_file : Com.Directory.relative Com.Path.t;
  to_file : Com.Directory.relative Com.Path.t;
  msg : string;
}
[@@deriving yojson]

type t = {
  from_area: Com.Area.t;
  from_subdirs: string list;
  to_area: Com.Area.t;
  to_subdirs: string list;
  directories_ok: result_directory_ok list;
  directories_ko: result_directory_error list;
  paths_ok: result_file_ok list;
  paths_ko: result_file_error list;
}
[@@deriving yojson]

let make ~from_area ~from_subdirs ~to_area ~to_subdirs ~directories_ok ~directories_ko ~paths_ok ~paths_ko =
  { from_area; from_subdirs; to_area; to_subdirs; directories_ok; directories_ko; paths_ok; paths_ko }

let make_directory_ok ~from_dir ~to_dir : result_directory_ok =
  { from_dir; to_dir }

let make_directory_error ~from_dir ~to_dir ~msg : result_directory_error =
  { from_dir; to_dir; msg }

let make_file_ok ~from_file ~to_file : result_file_ok =
  { from_file; to_file }

let make_file_error ~from_file ~to_file ~msg : result_file_error =
  { from_file; to_file; msg }

let get_from_area v = v.from_area
let get_from_subdirs v = v.from_subdirs
let get_to_area v = v.to_area
let get_to_subdirs v = v.to_subdirs
let get_directories_ok v = v.directories_ok
let get_directories_ko v = v.directories_ko
let get_paths_ok v = v.paths_ok
let get_paths_ko v = v.paths_ko

let get_directory_ok_from_dir (v : result_directory_ok) = v.from_dir
let get_directory_ok_to_dir (v : result_directory_ok) = v.to_dir
let get_directory_error_from_dir (v : result_directory_error) = v.from_dir
let get_directory_error_to_dir (v : result_directory_error) = v.to_dir
let get_directory_error_msg (v : result_directory_error) = v.msg
let get_file_ok_from_file (v : result_file_ok) = v.from_file
let get_file_ok_to_file (v : result_file_ok) = v.to_file
let get_file_error_from_file (v : result_file_error) = v.from_file
let get_file_error_to_file (v : result_file_error) = v.to_file
let get_file_error_msg (v : result_file_error) = v.msg

(*
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  selection: Selection_processed.t;
  target_area: Com.Area.t;
  target_subdirs: string list;
}
[@@deriving yojson]

let make ~selection ~target_area ~target_subdirs =
  { selection; target_area; target_subdirs }

let get_selection v = v.selection
let get_target_area v = v.target_area
let get_target_subdirs v = v.target_subdirs
*)