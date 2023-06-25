open Block

module Com = Shupdofi_com

type t = {
  route : Route_page.t;
  block : (Fetchable.id, Fetchable.status) Fetchable.t;
  areas : Com.Area.collection;
  area_content : Com.Area_content.t;
}

let empty = {
  route = Route_page.Home;
  block = Fetchable.default;
  areas = [];
  area_content = Com.Area_content.make ~id:"" ~subdirs:[] ~directories:[] ~files:[];
}

let set_route r v =
  { v with route = r }
