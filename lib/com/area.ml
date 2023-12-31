open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = { id: string; name: string; description: string }
[@@deriving yojson]

type collection = t list
[@@deriving yojson]

let make ~id ~name ~description = { id; name; description }

let empty =
  make ~id:"" ~name:"" ~description:""

let to_string v =
  Printf.sprintf "id = %s, name = %s, description = %s"
    v.id v.name v.description

let get_id v = v.id
let get_name v = v.name
let get_description v = v.description

let find_with_id id =
  List.find (fun e -> e.id = id)

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
