type t = {
  id: string;
  name: string;
  description: string;
}

let make ~id ~name ~description =
  { id; name; description }

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  Printf.sprintf "[groups.%s]\nname = %s\ndescription = %s" v.id (fmt v.name) (fmt v.description)

let get_id v =
  v.id

let get_name v =
  v.name

let get_description v =
  v.description
