module Routing = Shupdofi_clt_routing

module Fetchable : sig
  type id = private
    | Default_id
    | Areas
    | Area_content of string * string list
  type status
  type ('a, 'b) t = (id * status)

  val get_id : (id, status) t -> id
  val default : (id, status) t
  val areas : (id, status) t
  val area_content : string -> string list -> (id, status) t

  val is_loading : (id, status) t -> bool
  val is_loaded : (id, status) t -> bool

  val to_loading : (id, status) t -> (id, status) t
  val to_loaded : (id, status) t -> (id, status) t

  val route_api : (id, status) t -> Routing.Api.t
end