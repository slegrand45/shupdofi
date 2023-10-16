module Com = Shupdofi_com
module Intl = Shupdofi_clt_i18n.Intl
module Preferences = Shupdofi_clt_preferences.Preferences
module Routing = Shupdofi_clt_routing

type t = {
  preferences : Preferences.t;
  route : Routing.Page.t;
  block : (Block.Fetchable.id, Block.Fetchable.status) Block.Fetchable.t;
  areas : Com.Area.t list;
  area_content : Com.Area_content.t;
  sorting : Com.Sorting.t;
  modal : Modal.t;
  user : Com.User.t;
  selection : Com.Selection.t;
}

let default = 
  let prefs = Preferences.(empty |> set_lang (Some (Intl.user_language ()))) in
  {
    preferences = prefs;
    route = Routing.Page.Home;
    block = Block.Fetchable.default;
    areas = [];
    area_content = Com.Area_content.make ~area:Com.Area.empty ~subdirs:[] ~directories:[] ~files:[];
    sorting = Com.Sorting.default;
    modal = Modal.default;
    user = Com.User.empty;
    selection = Com.Selection.empty;
  }

let set_route r v =
  { v with route = r }
