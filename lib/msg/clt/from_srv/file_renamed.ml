(*
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
*)

module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.File_renamed

let get_area_id = Srv.get_area_id
let get_subdirs = Srv.get_subdirs
let get_old_file = Srv.get_old_file
let get_new_file = Srv.get_new_file
let t_of_yojson = Srv.t_of_yojson
