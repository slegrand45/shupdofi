open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type absolute
[@@deriving yojson]

type relative
[@@deriving yojson]

type 'a directory = {
  name: string;
  mdatetime: Datetime.t option;
}
[@@deriving yojson]

type 'a t = ('a directory) option
[@@deriving yojson]

let make_absolute ~name ?mdatetime () =
  let forbidden s =
    Str.string_match (Str.regexp_string Filename.parent_dir_name) s 0
    || Str.string_match (Str.regexp_string (Filename.dir_sep ^ Filename.dir_sep)) s 0
    || Str.string_match (Str.regexp (Filename.dir_sep ^ "$")) s 0
    || ((String.length s > 0) && (String.sub name 0 1 <> Filename.dir_sep))
    || String.length s = 0
  in
  if forbidden name then
    None
  else
    Some { name; mdatetime }

(* /!\ name can be empty *)
let make_relative ~name ?mdatetime () =
  let forbidden s =
    Str.string_match (Str.regexp_string Filename.parent_dir_name) s 0
    || Str.string_match (Str.regexp_string (Filename.dir_sep ^ Filename.dir_sep)) s 0
    || Str.string_match (Str.regexp (Filename.dir_sep ^ "$")) s 0
    || ((String.length s > 0) && (String.sub name 0 1 = Filename.dir_sep))
  in
  if forbidden name then
    None
  else
    Some { name; mdatetime }

let is_defined = function
  | None -> false
  | Some _ -> true

let get_name v =
  let f v = v.name in
  Option.fold ~some:f ~none:"" v

let get_mdatetime v =
  let f v = v.mdatetime in
  Option.fold ~some:f ~none:None v 

let set_name name v =
  let f v =
    Some { v with name }
  in
  Option.fold ~some:f ~none:v v

let set_mdatetime mdatetime v =
  let f v =
    Some { v with mdatetime }
  in
  Option.fold ~some:f ~none:v v
