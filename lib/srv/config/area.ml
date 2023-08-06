module Com = Shupdofi_com

type t = { area: Com.Area.t; root: Com.Directory.absolute Com.Directory.t }

type collection = t list

let make ~area ~root = { area; root }

let to_string v =
  Printf.sprintf "area = %s, root = %s"
    (Com.Area.to_string v.area) (Com.Directory.get_name v.root)

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  Printf.sprintf "[areas.%s]\nname = %s\ndescription = %s\nroot = %s"
    (Com.Area.get_id v.area) (fmt (Com.Area.get_name v.area))
    (fmt (Com.Area.get_description v.area)) (fmt (Com.Directory.get_name v.root))

let get_area v = v.area

let get_area_id v =
  Com.Area.get_id v.area

let get_root v = v.root

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
