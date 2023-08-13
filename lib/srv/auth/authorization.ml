module Com = Shupdofi_com
module Config = Shupdofi_srv_config

let groups_of_user config user =
  let open Config in
  Config.get_users config
  |> List.filter (fun e -> User.get_id e = User.get_id user)
  |> List.map User.get_groups
  |> List.flatten

let user_actions config user area =
  let open Config in
  let areas_accesses_of_area =
    Config.get_areas_accesses config
    |> List.filter (fun e -> Area_access.get_area e |> Area.get_area_id = Com.Area.get_id area)
  in
  let rights = List.map (Area_access.get_rights) areas_accesses_of_area |> List.flatten in
  let actions_user =
    List.map (Area_access.Right.get_action_of_user user) rights
    |> List.fold_left (fun acc e -> match e with None -> acc | Some v -> v :: acc) []
  in
  let groups_of_user = groups_of_user config user in
  let actions_groups =
    List.fold_left (fun acc_rights right -> 
        List.fold_left (fun acc_groups group ->
            (Area_access.Right.get_action_of_group group right) :: acc_rights
          ) [] groups_of_user
      ) [] rights
    |> List.fold_left (fun acc e -> match e with None -> acc | Some v -> v :: acc) []
  in
  List.sort_uniq compare (actions_user @ actions_groups)
(* List.iter (fun e -> prerr_endline (Printf.sprintf "%s " (Area_access.Action.to_string e))) actions; *)

let user_authorized_to config user action area =
  let actions = user_actions config user area in
  List.exists (fun e -> e = action) actions

let user_has_at_least_one_right config user area =
  let actions = user_actions config user area in
  List.length actions > 0