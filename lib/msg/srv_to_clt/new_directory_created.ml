open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  area_id: string;
  (* or Directory.t list ?? *)
  subdirs: string list;
  directory: Com.Directory.relative Com.Directory.t
}
[@@deriving yojson]

let make ~area_id ~subdirs ~directory = { area_id; subdirs; directory }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_directory v = v.directory
