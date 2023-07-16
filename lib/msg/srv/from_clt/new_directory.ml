(*
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  area_id: string;
  subdirs: string list;
  dirname: string;
}
[@@deriving yojson]

let make ~area_id ~subdirs ~dirname = { area_id; subdirs; dirname }
*)

module Clt = Shupdofi_msg_clt_to_srv.New_directory

let get_area_id = Clt.get_area_id
let get_subdirs = Clt.get_subdirs
let get_dirname = Clt.get_dirname
let t_of_yojson = Clt.t_of_yojson
