module Criteria = struct
  type t =
    | Name
    | Last_modified
    | Size

  let name = Name
  let last_modified = Last_modified
  let size = Size
end

module Direction = struct
  type t =
    | Ascending
    | Descending

  let ascending = Ascending
  let descending = Descending

  let alternate = function
    | Ascending -> Descending
    | Descending -> Ascending
end

type t = {
  criteria : Criteria.t;
  direction : Direction.t;
}

let make ~criteria ~direction =
  { criteria; direction }

let default = {
  criteria = Criteria.Name;
  direction = Direction.Ascending;
}

let get_criteria v =
  v.criteria

let get_direction v =
  v.direction
