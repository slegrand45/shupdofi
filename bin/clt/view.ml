module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing
module View = Shupdofi_clt_view

let view m =
  match m.Model.route with
  | Routing.Page.Home
  | Routing.Page.Areas ->
    (* mettre en mode chargement et lancer la requête pour récupérer les données *)
    (* let _ = Api_area.get_all Shupdofi_com.Page.(Section_user, Areas) in *)
    View.Layout.view m (View.Areas.view m)
  | Routing.Page.Area_content _ ->
    View.Layout.view m (View.Area_content.view m)