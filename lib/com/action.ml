open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  | Unknown of string
  | All
  | Download
  | Upload
  | Rename
  | Move
  | Delete
  | Create_directory
  | Archive
[@@deriving yojson]

let download = Download
let upload = Upload
let rename = Rename
let move = Move
let delete = Delete
let create_directory = Create_directory
let archive = Archive

let from_string = function
  | "*" -> All
  | "download" -> Download
  | "upload" -> Upload
  | "rename" -> Rename
  | "move" -> Move
  | "delete" -> Delete
  | "create_directory" -> Create_directory
  | "archive" -> Archive
  | s -> Unknown s

let to_toml = function
  | All -> "\"*\""
  | Download -> "download"
  | Upload -> "upload"
  | Rename -> "rename"
  | Move -> "move"
  | Delete -> "delete"
  | Create_directory -> "create_directory"
  | Archive -> "archive"
  | Unknown _ -> "unknown"

let to_string = to_toml

let is_unknown = function
  | Unknown _ -> true
  | _ -> false