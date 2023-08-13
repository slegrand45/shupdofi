module Id = struct

  type t =
    | Unknown of string
    | Http_header

  let from_string = function
    | "http_header" -> Http_header
    | s -> Unknown s

  let to_string = function
    | Http_header -> "http_header"
    | Unknown s -> s

  let is_unknown = function
    | Unknown _ -> true
    | _ -> false

end

module Http_header = struct

  type t = {
    header_login : string;
  }

  let make ~header_login =
    { header_login }

  let get_header_login v =
    v.header_login

  let to_toml v =
    let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
    Printf.sprintf "[authentications.http_header]\nheader_login = %s" (fmt v.header_login)

end

type t =
  | Http_header of Http_header.t

let make_http_header v =
  Http_header v

let to_toml = function
  | Http_header v -> Http_header.to_toml v