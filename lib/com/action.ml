open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  | Unknown of string
  | All
  | Download
  | Upload
  | Rename
  | Delete
  | Create_directory
[@@deriving yojson]

let all = All
let download = Download
let upload = Upload
let rename = Rename
let delete = Delete
let create_directory = Create_directory

let from_string = function
  | "*" -> All
  | "download" -> Download
  | "upload" -> Upload
  | "rename" -> Rename
  | "delete" -> Delete
  | "create_directory" -> Create_directory
  | s -> Unknown s

let to_toml = function
  | All -> "\"*\""
  | Download -> "download"
  | Upload -> "upload"
  | Rename -> "rename"
  | Delete -> "delete"
  | Create_directory -> "create_directory"
  | Unknown _ -> "unknown"

let to_string = to_toml

let is_unknown = function
  | Unknown _ -> true
  | _ -> false