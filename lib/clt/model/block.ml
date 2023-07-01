module Routing = Shupdofi_clt_routing

module Fetchable = struct
  type id =
    | Default_id
    | Areas
    | Area_content of string * string list

  type status =
    | Default_status
    | Loading
    | Loaded

  type ('a, 'b) t = (id * status)

  let default = (Default_id, Default_status)
  let areas = (Areas, Default_status)
  let area_content id subdirs = (Area_content (id, subdirs), Default_status)

  let get_id (id, _) = id

  let is_loading = function
    | (_, Loading) -> true
    | (_, _) -> false

  let is_loaded = function
    | (_, Loaded) -> true
    | (_, _) -> false

  let to_loading = function
    | (id, _) -> (id, Loading)

  let to_loaded = function
    | (id, _) -> (id, Loaded)

  let route_api = function
    | (Areas, _) -> Routing.Api.Areas
    | (Area_content (id, subdirs) , _) -> Routing.Api.Area_content (id, subdirs)
    | _ -> assert false

end