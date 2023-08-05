module Id : sig

  type t = private
    | Unknown of string
    | Http_header

  val from_string : string -> t
  val to_string : t -> string
  val is_unknown : t -> bool
end

module Http_header : sig
  type t

  val make : header_name_for_login:string -> t
  val to_toml : t -> string
end

type t

val make_http_header : Http_header.t -> t
val to_toml : t -> string
