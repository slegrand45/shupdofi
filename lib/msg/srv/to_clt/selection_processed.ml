open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  area: Com.Area.t;
  subdirs: string list;
  directories_ok: (Com.Directory.relative Com.Directory.t * Com.Directory.relative Com.Directory.t option) list;
  directories_ko: Com.Directory.relative Com.Directory.t list;
  paths_ok: (Com.Directory.relative Com.Path.t * Com.Directory.relative Com.Path.t option) list;
  paths_ko: Com.Directory.relative Com.Path.t list;
}
[@@deriving yojson]

let make ~area ~subdirs ~directories_ok ~directories_ko ~paths_ok ~paths_ko =
  { area; subdirs; directories_ok; directories_ko; paths_ok; paths_ko }

let get_area v = v.area
let get_subdirs v = v.subdirs
let get_directories_ok v = v.directories_ok
let get_directories_ko v = v.directories_ko
let get_paths_ok v = v.paths_ok
let get_paths_ko v = v.paths_ko