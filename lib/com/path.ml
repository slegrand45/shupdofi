open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type path = {
  directory: Directory.t;
  file: File.t;
}
[@@deriving yojson]

type t = path option
[@@deriving yojson]

let make directory file =
  match Directory.is_defined directory, File.is_defined file with
  | true, true -> Some { directory; file }
  | _ -> None

let is_defined = function
  | None -> false
  | Some _ -> true  

let get_directory = function
  | None -> None
  | Some v -> Some v.directory

let get_file = function
  | None -> None
  | Some v -> Some v.file

let set_directory directory = function
  | None -> None
  | Some v -> Some { v with directory }

let set_file file = function
  | None -> None
  | Some v -> Some { v with file }
