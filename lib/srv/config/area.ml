module Com = Shupdofi_com

type t = { area: Com.Area.t; root: Com.Directory.absolute Com.Directory.t; quota: (string * Com.Size.t option) }

type collection = t list

let make ~area ~root ~quota = { area; root; quota }

let to_string v =
  let quota =
    let (_, q) = v.quota in
    match q with
    | Some v -> Com.Size.to_human v
    | None -> "none"
  in
  Printf.sprintf "area = %s, root = %s, quota = %s"
    (Com.Area.to_string v.area) (Com.Directory.get_name v.root) quota

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  let quota =
    let (s, q) = v.quota in
    match q with
    | Some _ -> Printf.sprintf "\nquota = %s" (fmt s)
    | None -> ""
  in
  Printf.sprintf "[areas.%s]\nname = %s\ndescription = %s\nroot = %s%s"
    (Com.Area.get_id v.area) (fmt (Com.Area.get_name v.area))
    (fmt (Com.Area.get_description v.area)) (fmt (Com.Directory.get_name v.root)) quota

let get_area v = v.area

let get_area_id v =
  Com.Area.get_id v.area

let get_root v = v.root

let get_quota v = v.quota

(*
let get_all : type a. a t -> a list = fun v -> 
  match v with
  | No_data -> []
  | User_data v -> [ v ]
  | User_collection v -> v
  | Admin_data v -> [ v ]
  | Admin_collection v -> v
*)

(*
let get_all : type a. (Profile.t * Page.t) -> t list = fun ctx -> 
  match ctx with
  | (Profile.User, Page.(Section_user, Areas))
  | (Profile.Admin, Page.(Section_user, Areas)) -> [ User_data v1_areas ]
  | (Profile.Admin, Page.(Section_admin, Areas)) -> [ Admin_data v1_areas_admin ]
  | _ -> [ ]
*)
