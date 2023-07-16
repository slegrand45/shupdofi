(*
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  filename: string;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~filename = { area_id; subdirs; filename }
*)

module Clt = Shupdofi_msg_clt_to_srv.Delete_file

let get_area_id = Clt.get_area_id
let get_subdirs = Clt.get_subdirs
let get_filename = Clt.get_filename
let t_of_yojson = Clt.t_of_yojson
