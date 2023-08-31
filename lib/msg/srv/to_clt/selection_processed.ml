open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  area: Com.Area.t;
  subdirs: string list;
  directories_ok: Com.Directory.relative Com.Directory.t list;
  directories_ko: Com.Directory.relative Com.Directory.t list;
  files_ok: Com.File.t list;
  files_ko: Com.File.t list;
}
[@@deriving yojson]

let make ~area ~subdirs ~directories_ok ~directories_ko ~files_ok ~files_ko =
  { area; subdirs; directories_ok; directories_ko; files_ok; files_ko }

let get_area v = v.area
let get_subdirs v = v.subdirs
let get_directories_ok v = v.directories_ok
let get_directories_ko v = v.directories_ko
let get_files_ok v = v.files_ok
let get_files_ko v = v.files_ko