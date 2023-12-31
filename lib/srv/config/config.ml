module Com = Shupdofi_com
module Toml = Otoml.Base.Make (Otoml.Base.OCamlNumber) (Otoml.Base.StringDate)

type t = {
  server: Server.t;
  application: Application.t;
  authentications: Authentication.t list;
  areas: Area.t list;
  groups: Group.t list;
  users: User.t list;
  areas_accesses: Area_access.t list
}

let to_toml v =
  let server = Server.to_toml v.server in
  let application = Application.to_toml v.application in
  let authentications = List.map (fun e -> Printf.sprintf "%s" (Authentication.to_toml e)) v.authentications |> String.concat "\n\n" in
  let areas = List.map (fun e -> Printf.sprintf "%s" (Area.to_toml e)) v.areas |> String.concat "\n\n" in
  let groups = List.map (fun e -> Printf.sprintf "%s" (Group.to_toml e)) v.groups |> String.concat "\n\n" in
  let users = List.map (fun e -> Printf.sprintf "%s" (User.to_toml e)) v.users |> String.concat "\n\n" in
  let areas_accesses = List.map (fun e -> Printf.sprintf "%s" (Area_access.to_toml e)) v.areas_accesses |> String.concat "\n\n" in
  Printf.sprintf "\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n" server application authentications areas groups users areas_accesses

let get_server v =
  v.server

let get_application v =
  v.application

let get_authentications v =
  v.authentications

let get_areas v =
  v.areas

let get_groups v =
  v.groups

let get_users v =
  v.users

let get_areas_accesses v =
  v.areas_accesses

let find_area_with_id id v =
  List.find (fun e -> (Area.get_area_id e) = id) v.areas

let map_values f tab =
  let (oks, errs) = List.map f tab |> List.partition (Result.is_ok) in
  match oks, errs with
  | oks, [] ->
    List.map Result.get_ok oks |> Result.ok
  | _, errs ->
    List.map Result.get_error errs |> String.concat "\n" |> Result.error

let required_section_from_toml toml name f msg_err =
  let tab = Toml.find_opt toml (Toml.get_value) [name] in
  match tab with
  | Some tab -> f tab
  | None -> Result.error msg_err

let optional_section_from_toml toml name f default =
  let tab = Toml.find_opt toml (Toml.get_value) [name] in
  match tab with
  | Some tab -> f tab
  | None -> Result.ok default

  (*
let check_uniq_id f_get_id f_msg_err l =
  match l with
  | Ok l_ok -> (
      let ids = List.map f_get_id l_ok |> List.sort compare in
      let rec f acc l =
        match acc with
        | None -> (
            match l with
            | [] -> acc
            | v::[] -> acc
            | v1::v2::l when v1 = v2 -> f (Some v1) l
            | v1::v2::l -> f acc l
          )
        | Some _ as v -> v
      in
      match f None ids with
      | None -> l
      | Some v -> Result.error (f_msg_err v)
    )
  | Error _ as err -> err
*)

let server_from_toml toml =
  let www_root = Toml.Helpers.find_string_result toml ["www_root"] in
  let listen_address = Toml.Helpers.find_string_result toml ["listen_address"] in
  let listen_port = Toml.Helpers.find_integer_result toml ["listen_port"] in
  match www_root, listen_address, listen_port with
  | Ok root, Ok addr, Ok port ->
    let dir = Com.Directory.make_absolute ~name:root () in
    if (Com.Directory.is_defined dir) then
      let server = Server.make ~www_root:dir ~listen_address:addr ~listen_port:port in
      Result.ok server
    else
      Result.error "[server]: www_root must be an absolute path"
  | Error _, _, _ ->
    Result.error "[server]: www_root is missing"
  | _, Error _, _ ->
    Result.error "[server]: listen_address is missing"
  | _, _, Error _ ->
    Result.error "[server]: listen_port is missing"

let application_from_toml toml =
  let authentications = Toml.Helpers.find_strings_result toml ["authentications"] in
  match authentications with
  | Ok ids -> (
      let ids = List.map Authentication.Id.from_string ids in
      let (errs, oks) = List.partition Authentication.Id.is_unknown ids in
      match errs, oks with
      | [], _::_ ->
        let application = Application.make ~authentications:oks in
        Result.ok application
      | _::_, _ ->
        let s = List.map Authentication.Id.to_string errs |> String.concat ", " in
        Result.error (Printf.sprintf "[application]: unknown authentication(s) %s" s)
      | _, [] ->
        Result.error "[application]: authentications cannot be empty"
    )
  | Error _ ->
    Result.error "[application]: authentications are missing"

let authentications_from_toml toml =
  let tab = Toml.get_table toml in
  let f (id, toml) =
    match Authentication.Id.from_string id with
    | Authentication.Id.Unknown _ ->
      Result.error (Printf.sprintf "[authentications.%s] auth method %s is unknown" id id)
    | Authentication.Id.Http_header -> (
        match Toml.Helpers.find_string_result toml ["header_login"] with
        | Ok header_login ->
          Result.ok (Authentication.make_http_header (Authentication.Http_header.make ~header_login))
        | Error _ ->
          Result.error (Printf.sprintf "[authentications.%s] header_login is missing" id)
      )
  in
  map_values f tab

let areas_from_toml toml =
  let tab = Toml.get_table toml in
  let f (id, toml) =
    let name = Toml.Helpers.find_string_result toml ["name"] in
    let description = Toml.Helpers.find_string_result toml ["description"] in
    let root = Toml.Helpers.find_string_result toml ["root"] in
    let quota =
      match Toml.Helpers.find_string_opt toml ["quota"] with
      | None -> ("", None)
      | Some s -> (s, Com.Size.from_string s)
    in
    match name, description, root with
    | Ok name, Ok description, Ok root ->
      let dir = Com.Directory.make_absolute ~name:root () in
      if (Com.Directory.is_defined dir) then
        let com_area = Com.Area.make ~id ~name ~description in
        Result.ok (Area.make ~area:com_area ~root:dir ~quota)
      else
        Result.error (Printf.sprintf "[areas.%s] root must be an absolute path" id)
    | Error _, Ok _, Ok _ ->
      Result.error (Printf.sprintf "[areas.%s] name is missing" id)
    | Ok _, Error _, Ok _ ->
      Result.error (Printf.sprintf "[areas.%s] description is missing" id)
    | Ok _, Ok _, Error _ ->
      Result.error (Printf.sprintf "[areas.%s] root is missing" id)
    | _ ->
      Result.error (Printf.sprintf "[areas.%s] name, description or root are missing" id)
  in
  map_values f tab

let groups_from_toml toml =
  let tab = Toml.get_table toml in
  let f (id, toml) =
    let name = Toml.Helpers.find_string_result toml ["name"] in
    let description = Toml.Helpers.find_string_result toml ["description"] in
    match name, description with
    | Ok name, Ok description ->
      Result.ok (Group.make ~id ~name ~description)
    | Error _, Ok _ ->
      Result.error (Printf.sprintf "[groups.%s] name is missing" id)
    | Ok _, Error _ ->
      Result.error (Printf.sprintf "[groups.%s] description is missing" id)
    | _ ->
      Result.error (Printf.sprintf "[groups.%s] name or description are missing" id)
  in
  map_values f tab

let users_from_toml groups toml =
  let tab = Toml.get_table toml in
  let f (id, toml) =
    let login = Toml.Helpers.find_string_result toml ["login"] in
    let name = Toml.Helpers.find_string_result toml ["name"] in
    let groups =
      match Toml.find_opt toml (Toml.get_array Toml.get_string) ["groups"] with
      | None ->
        Result.error (Printf.sprintf "[users.%s] groups is missing (use \"groups = []\" if the user doesn't belong to any group)" id)
      | Some str_groups -> (
          let f s =
            match List.find_opt (fun g -> s = Group.get_id g) groups with
            | None -> Result.error s
            | Some g -> Result.ok g
          in
          let l = List.map f str_groups in
          match List.partition Result.is_ok l with
          | oks, [] ->
            Result.ok (List.map Result.get_ok oks)
          | _, errs ->
            let msg = List.map Result.get_error errs |> String.concat ", " in
            Result.error (Printf.sprintf "[users.%s] group(s) %s are unknown" id msg)
        )
    in
    match login, name, groups with
    | Ok login, Ok name, Ok groups ->
      Result.ok (User.make ~id ~login ~name ~groups)
    | Error _, Ok _, Ok _ ->
      Result.error (Printf.sprintf "[users.%s] login is missing" id)
    | Ok _, Error _, Ok _ ->
      Result.error (Printf.sprintf "[users.%s] name is missing" id)
    | Ok _, Ok _, (Error _ as err) ->
      err
    | _ ->
      Result.error (Printf.sprintf "[users.%s] login or name are missing" id)
  in
  map_values f tab

let has_pct_wildcard s =
  match String.index_opt s '%' with
  | None -> false
  | Some _ -> true

let make_right_users known str_action toml =
  let action = Com.Action.from_string str_action in
  match Com.Action.is_unknown action with
  | false -> (
      let l = Toml.get_array Toml.get_string toml in
      match l with
      | [] ->
        Result.error (Printf.sprintf "invalid users list for action %s" str_action)
      | v ->
        if List.exists (fun e -> e = "*") v then
          Result.ok (Area_access.(Right.make_right_users action Users.all))
        else
          let f e =
            match e with
            | s when (has_pct_wildcard s) ->
              Result.ok (Area_access.User.wildcard s)
            | s ->
              match List.find_opt (fun e -> User.get_id e = s) known with
              | None -> Result.error s
              | Some a -> Result.ok (Area_access.User.make a)
          in
          match List.map f v |> List.partition Result.is_ok with
          | oks, [] ->
            Result.ok (Area_access.(Right.make_right_users action (Users.make (List.map Result.get_ok oks))))
          | _, errs ->
            let msg = List.map Result.get_error errs |> String.concat ", " in
            Result.error (Printf.sprintf "user(s) %s unknown for action %s" msg str_action)
    )
  | true ->
    Result.error (Printf.sprintf "action %s is unknown" str_action)

let make_right_groups known str_action toml =
  let action = Com.Action.from_string str_action in
  match Com.Action.is_unknown action with
  | false -> (
      let l = Toml.get_array Toml.get_string toml in
      match l with
      | [] ->
        Result.error (Printf.sprintf "invalid groups list for action %s" str_action)
      | v ->
        if List.exists (fun e -> e = "*") v then
          Result.ok (Area_access.(Right.make_right_groups action Groups.all))
        else
          let f e =
            match e with
            | s when (has_pct_wildcard s) ->
              Result.ok (Area_access.Group.wildcard s)
            | s ->
              match List.find_opt (fun e -> Group.get_id e = s) known with
              | None -> Result.error s
              | Some a -> Result.ok (Area_access.Group.make a)
          in
          match List.map f v |> List.partition Result.is_ok with
          | oks, [] ->
            Result.ok (Area_access.(Right.make_right_groups action (Groups.make (List.map Result.get_ok oks))))
          | _, errs ->
            let msg = List.map Result.get_error errs |> String.concat ", " in
            Result.error (Printf.sprintf "group(s) %s unknown for action %s" msg str_action)
    )
  | true ->
    Result.error (Printf.sprintf "action %s is unknown" str_action)

let areas_accesses_from_toml areas users groups toml =
  let tab = Toml.get_table toml in
  let f_area (area_id, toml) =
    match List.find_opt (fun e -> Area.get_area_id e = area_id) areas with
    | None ->
      Result.error (Printf.sprintf "[areas_accesses.%s] area %s is unknown" area_id area_id)
    | Some area ->
      let rights_users =
        match Toml.find_opt toml (Toml.get_table) ["rights"; "users"] with
        | Some ru -> (
            let f (action, toml) = make_right_users users action toml in
            match List.map f ru |> List.partition Result.is_ok with
            | oks, [] ->
              Result.ok (List.map Result.get_ok oks)
            | _, errs ->
              let msg = List.map Result.get_error errs |> String.concat ", " in
              Result.error (Printf.sprintf "[areas_accesses.%s] %s" area_id msg)
          )
        | None ->
          Result.ok []
      in
      let rights_groups =
        match Toml.find_opt toml (Toml.get_table) ["rights"; "groups"] with
        | Some rg -> (
            let f (action, toml) = make_right_groups groups action toml in
            match List.map f rg |> List.partition Result.is_ok with
            | oks, [] ->
              Result.ok (List.map Result.get_ok oks)
            | _, errs ->
              let msg = List.map Result.get_error errs |> String.concat ", " in
              Result.error (Printf.sprintf "[areas_accesses.%s] %s" area_id msg)
          )
        | None ->
          Result.ok []
      in
      match rights_users, rights_groups with
      | Ok ru, Ok rg ->
        Result.ok (Area_access.(make area (ru @ rg)))
      | Error err1, Error err2 ->
        Result.error (err1 ^ err2)
      | Error _ as r, _ ->
        r
      | _, (Error _ as r) ->
        r
  in
  map_values f_area tab

let from_toml_file file =
  try
    let toml = Toml.Parser.from_file file in
    let server = required_section_from_toml toml "server" server_from_toml "[server] section is missing" in
    let application = required_section_from_toml toml "application" application_from_toml "[application] section is missing" in
    let authentications = required_section_from_toml toml "authentications" authentications_from_toml "No authentication found" in
    let areas = required_section_from_toml toml "areas" areas_from_toml "No area found" in
    (* |> check_uniq_id Area.get_area_id (fun s -> Printf.sprintf "[area.%s] section is not unique" s) *)
    match server, application, authentications, areas with
    | Ok server, Ok application, Ok authentications, Ok areas -> (
        let groups = optional_section_from_toml toml "groups" groups_from_toml [] in
        match groups with
        | Ok groups -> (
            let users = required_section_from_toml toml "users" (users_from_toml groups) "No user found" in
            match users with
            | Ok users -> (
                let areas_accesses = required_section_from_toml toml "areas_accesses" (areas_accesses_from_toml areas users groups) "No area access found" in
                match areas_accesses with
                | Ok areas_accesses ->
                  Result.ok { server; application; authentications; areas; groups; users; areas_accesses }
                | Error _ as err -> err
              )
            | Error _ as err -> err
          )
        | Error _ as err -> err
      )
    | (Error _ as err), _, _, _ -> err
    | _, (Error _ as err), _, _ -> err
    | _, _, (Error _ as err), _ -> err
    | _, _, _, (Error _ as err) -> err
  with
  | Toml.Parse_error (pos, err) ->
    Result.error (Toml.Parser.format_parse_error pos err)
