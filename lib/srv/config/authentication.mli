module Id : sig
  type t

  val from_string : string -> t
  val to_string : t -> string
  val is_unknown : t -> bool
end

module Http_header : sig
  type t

  val make : header_name_for_login:string -> t
  val to_toml : t -> string
end
