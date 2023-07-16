open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  area_id: string;
  (* or Directory.t list ?? *)
  subdirs: string list;
  old_file: Com.File.t;
  new_file: Com.File.t;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~old_file ~new_file = { area_id; subdirs; old_file; new_file }

let get_area_id v = v.area_id
let get_subdirs v = v.subdirs
let get_old_file v = v.old_file
let get_new_file v = v.new_file
