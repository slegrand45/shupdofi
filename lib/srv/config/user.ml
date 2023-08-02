type t = {
  id: string;
  login: string;
  name: string;
  groups: Group.t list;
}

let make ~id ~login ~name ~groups =
  { id; login; name; groups }

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  let str_groups = List.map (fun e -> Group.get_id e |> fmt) v.groups |> String.concat ", " in
  Printf.sprintf "[users.%s]\nlogin = %s\nname = %s\ngroups = [ %s ]" v.id (fmt v.login) (fmt v.name) str_groups

let get_id v =
  v.id

let get_login v =
  v.login

let get_name v =
  v.name

let get_groups v =
  v.groups
