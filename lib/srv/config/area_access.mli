module Com = Shupdofi_com

module Config_group = Group
module Config_user = User

module User : sig
  type t

  val wildcard : string -> t
  val make : Config_user.t -> t
end

module Group : sig
  type t

  val wildcard : string -> t
  val make : Config_group.t -> t
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

  val make_right_users : Com.Action.t -> Users.t -> t
  val make_right_groups : Com.Action.t -> Groups.t -> t
  val get_action_of_user : Config_user.t -> t -> Com.Action.t option
  val get_action_of_group : Config_group.t -> t -> Com.Action.t option
end

type t

val make : Area.t -> Right.t list -> t
val get_area : t -> Area.t
val get_rights : t -> Right.t list
val to_toml : t -> string
