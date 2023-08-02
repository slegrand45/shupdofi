module Com = Shupdofi_com

module Action = struct
  type t =
    | Unknown
    | All
    | Download
    | Upload
    | Rename
    | Move
    | Delete
    | Create_directory

  let from_string = function
    | "*" -> All
    | "download" -> Download
    | "upload" -> Upload
    | "rename" -> Rename
    | "move" -> Move
    | "delete" -> Delete
    | "create_directory" -> Create_directory
    | _ -> Unknown

  let to_toml = function
    | All -> "\"*\""
    | Download -> "download"
    | Upload -> "upload"
    | Rename -> "rename"
    | Move -> "move"
    | Delete -> "delete"
    | Create_directory -> "create_directory"
    | Unknown -> "unknown"

  let is_unknown = function
    | Unknown -> true
    | _ -> false
end

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
end

module Right = struct
  type t =
    | Right_users of (Action.t * Users.t)
    | Right_groups of (Action.t * Groups.t)

  let make_right_users action users =
    Right_users (action, users)

  let make_right_groups action groups =
    Right_groups (action, groups)

  let to_toml = function
    | Right_users (action, users) ->
      Printf.sprintf "rights.users.%s = [ %s ]" (Action.to_toml action) (Users.to_toml users)
    | Right_groups (action, groups) ->
      Printf.sprintf "rights.groups.%s = [ %s ]" (Action.to_toml action) (Groups.to_toml groups)

end

type t = (Com.Area.t * Right.t list)

let make area rights =
  (area, rights)

let to_toml (area, rights) =
  Printf.sprintf "[areas_accesses.%s]\n%s" (Com.Area.get_id area) (List.map Right.to_toml rights |> String.concat "\n")