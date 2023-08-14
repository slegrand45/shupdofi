open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  name: string;
  areas_rights: (string * Action.t list) list;
}
[@@deriving yojson]

let make ~name ~areas_rights =
  { name; areas_rights }

let empty =
  make ~name:"" ~areas_rights:[]

let get_name v =
  v.name

let get_areas_rights v =
  v.areas_rights
