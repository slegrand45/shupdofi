module Routing = Shupdofi_clt_routing
module Com = Shupdofi_com

type t = {
  route : Routing.Page.t;
  block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t;
  areas : Com.Area.collection;
  area_content : Com.Area_content.t;
  modal : Modal.t;
}

let empty = {
  route = Routing.Page.Home;
  block = Block.Fetchable.default;
  areas = [];
  area_content = Com.Area_content.make ~id:"" ~subdirs:[] ~directories:[] ~files:[];
  modal = Modal.default;
}

let set_route r v =
  { v with route = r }
