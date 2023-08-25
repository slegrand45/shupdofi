open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t = {
  name: string;
  areas_rights: (string * Action.t list) list;
}
[@@deriving yojson]

let make ~name ~areas_rights =
  { name; areas_rights }

let empty =
  make ~name:"" ~areas_rights:[]

let get_name v =
  v.name

let get_areas_rights v =
  v.areas_rights

let can_do_action ~area_id ~action v =
  let areas_rights = v.areas_rights in
  match List.find_opt (fun (id, _) -> id = area_id) areas_rights with
  | None -> false
  | Some (_, al) ->
    match List.find_opt (fun e -> e = action || e = Action.all) al with
    | None -> false
    | _ -> true