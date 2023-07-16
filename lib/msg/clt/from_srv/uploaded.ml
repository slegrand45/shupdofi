(*
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Com = Shupdofi_com

type t = {
  area_id: string;
  (* or Directory.t list ?? *)
  subdirs: string list;
  file: Com.File.t
}
[@@deriving yojson]

let make ~area_id ~subdirs ~file = { area_id; subdirs; file }
*)

module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.Uploaded

let get_area_id = Srv.get_area_id
let get_subdirs = Srv.get_subdirs
let get_file = Srv.get_file
let t_of_yojson = Srv.t_of_yojson
