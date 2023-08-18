module Com = Shupdofi_com
module Routing = Shupdofi_clt_routing

type t = {
  route : Routing.Page.t;
  block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t;
  areas : Com.Area.t list;
  area_content : Com.Area_content.t;
  sorting : Com.Sorting.t;
  modal : Modal.t;
  user : Com.User.t;
}

let empty = {
  route = Routing.Page.Home;
  block = Block.Fetchable.default;
  areas = [];
  area_content = Com.Area_content.make ~area:Com.Area.empty ~subdirs:[] ~directories:[] ~files:[];
  sorting = Com.Sorting.default;
  modal = Modal.default;
  user = Com.User.empty;
}

let set_route r v =
  { v with route = r }
