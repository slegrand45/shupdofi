open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type file = {
  name: string;
  size_bytes: int64 option;
  mdatetime: Datetime.t option;
}
[@@deriving yojson]

type t = file option
[@@deriving yojson]

let make ~name ?size_bytes ?mdatetime () =
  let forbidden s =
    Str.string_match (Str.regexp_string Filename.parent_dir_name) s 0
    || Str.string_match (Str.regexp_string Filename.dir_sep) s 0
    || String.length s = 0
  in
  if forbidden name then
    None
  else
    Some { name; size_bytes; mdatetime }

let is_defined = function
  | None -> false
  | Some _ -> true

let get_name v =
  let f v = v.name in
  Option.fold ~some:f ~none:"" v

let get_size_bytes v =
  let f v = v.size_bytes in
  Option.fold ~some:f ~none:None v

let get_mdatetime v =
  let f v = v.mdatetime in
  Option.fold ~some:f ~none:None v

let set_name name v =
  let f v =
    Some { v with name }
  in
  Option.fold ~some:f ~none:v v

let set_size_bytes size v =
  let f v =
    Some { v with size_bytes = size }
  in
  Option.fold ~some:f ~none:v v

let set_mdatetime mdatetime v =
  let f v =
    Some { v with mdatetime }
  in
  Option.fold ~some:f ~none:v v
