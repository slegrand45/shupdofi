type t = {
  authentications: Authentication.Id.t list;
}

let make ~authentications =
  { authentications }

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  let str_authentications = List.map (fun e -> Authentication.Id.to_string e |> fmt) v.authentications |> String.concat ", " in
  Printf.sprintf "[application]\nauthentications = [ %s ]" str_authentications

let get_authentications v =
  v.authentications