open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  area_id: string;
  (* or Directory.t list ?? *)
  subdirs: string list;
  old_directory: Com.Directory.relative Com.Directory.t;
  new_directory: Com.Directory.relative Com.Directory.t;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~old_directory ~new_directory = { area_id; subdirs; old_directory; new_directory }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_old_directory v = v.old_directory
let get_new_directory v = v.new_directory
