(*
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
*)

module Com = Shupdofi_com
module Srv = Shupdofi_msg_srv_to_clt.New_directory_created

let get_area_id = Srv.get_area_id
let get_subdirs = Srv.get_subdirs
let get_directory = Srv.get_directory
let t_of_yojson = Srv.t_of_yojson
