module Action : sig
  type t

  val from_string : string -> t
  val is_unknown : t -> bool
end

module User : sig
  type t

  val wildcard : string -> t
  val make : User.t -> t
end

module Group : sig
  type t

  val wildcard : string -> t
  val make : Group.t -> t
end

module Users : sig
  type t

  val all : t
  val make : User.t list -> t
end

module Groups : sig
  type t

  val all : t
  val make : Group.t list -> t
end

module Right : sig
  type t

  val make_right_users : Action.t -> Users.t -> t
  val make_right_groups : Action.t -> Groups.t -> t
end

type t

val make : Area.t -> Right.t list -> t
val to_toml : t -> string
