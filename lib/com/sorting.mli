module Criteria : sig
  type t = private
    | Name
    | Last_modified
    | Size

  val name : t
  val last_modified : t
  val size : t
end

module Direction : sig
  type t = private
    | Ascending
    | Descending

  val ascending : t
  val descending : t
  val alternate : t -> t
end

type t

val make : criteria:Criteria.t -> direction:Direction.t -> t
val default : t
val get_criteria : t -> Criteria.t
val get_direction : t -> Direction.t
