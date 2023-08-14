module Com = Shupdofi_com
module Config_group = Group
module Config_user = User

module User = struct
  type t =
    | Actor of User.t
    | Wildcard of (string * Str.regexp)

  let to_toml v =
    let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
    match v with
    | Actor v -> fmt (User.get_id v)
    | Wildcard (s, _) -> fmt s

  let wildcard s =
    let regexp_dot = Str.regexp_string "." in
    let regexp_pct = Str.regexp_string "%" in
    let regexp = Str.(regexp (
        global_replace regexp_dot "\\." s |> global_replace regexp_pct ".*"
      )) in
    Wildcard (s, regexp)

  let make a =
    Actor a

  let is ref_user = function
    | Actor u -> User.get_id ref_user = User.get_id u
    | Wildcard (_, r) -> Str.string_match r (User.get_id ref_user) 0

end

module Group = struct
  type t =
    | Actor of Group.t
    | Wildcard of (string * Str.regexp)

  let to_toml v =
    let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
    match v with
    | Actor v -> fmt (Group.get_id v)
    | Wildcard (s, _) -> fmt s

  let wildcard s =
    let regexp_dot = Str.regexp_string "." in
    let regexp_pct = Str.regexp_string "%" in
    let regexp = Str.(regexp (
        global_replace regexp_dot "\\." s |> global_replace regexp_pct ".*"
      )) in
    Wildcard (s, regexp)

  let make a =
    Actor a

  let is ref_group = function
    | Actor g -> Group.get_id ref_group = Group.get_id g
    | Wildcard (_, r) -> Str.string_match r (Group.get_id ref_group) 0

end

module Users = struct
  type t =
    | All
    | Actors of User.t list

  let to_toml = function
    | All -> "\"*\""
    | Actors l -> List.map User.to_toml l |> String.concat ", "

  let all =
    All

  let make l =
    Actors l

  let has_user user = function
    | All -> true
    | Actors l -> List.exists (User.is user) l

end

module Groups = struct
  type t =
    | All
    | Actors of Group.t list

  let to_toml = function
    | All -> "\"*\""
    | Actors l -> List.map Group.to_toml l |> String.concat ", "

  let all =
    All

  let make l =
    Actors l

  let has_group group = function
    | All -> true
    | Actors l -> List.exists (Group.is group) l

end

module Right = struct
  type t =
    | Right_users of (Com.Action.t * Users.t)
    | Right_groups of (Com.Action.t * Groups.t)

  let make_right_users action users =
    Right_users (action, users)

  let make_right_groups action groups =
    Right_groups (action, groups)

  let get_action_of_user user = function
    | Right_users (action, users) -> (
        match Users.has_user user users with
        | true -> Some action
        | _ -> None
      )
    | _ -> None

  let get_action_of_group group = function
    | Right_groups (action, groups) -> (
        match Groups.has_group group groups with
        | true -> Some action
        | _ -> None
      )
    | _ -> None

  let to_toml = function
    | Right_users (action, users) ->
      Printf.sprintf "rights.users.%s = [ %s ]" (Com.Action.to_toml action) (Users.to_toml users)
    | Right_groups (action, groups) ->
      Printf.sprintf "rights.groups.%s = [ %s ]" (Com.Action.to_toml action) (Groups.to_toml groups)

end

type t = (Area.t * Right.t list)

let make area rights =
  (area, rights)

let get_area (area, _) =
  area

let get_rights (_, rights) =
  rights

let to_toml (area, rights) =
  Printf.sprintf "[areas_accesses.%s]\n%s" (Area.get_area_id area)
    (List.map Right.to_toml rights |> String.concat "\n")