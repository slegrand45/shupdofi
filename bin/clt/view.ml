open Shupdofi_clt.Model

let view m =
  match m.route with
  | Shupdofi_clt.Route_page.Home
  | Shupdofi_clt.Route_page.Areas ->
    (* mettre en mode chargement et lancer la requête pour récupérer les données *)
    (* let _ = Api_area.get_all Shupdofi_com.Page.(Section_user, Areas) in *)
    View_layout.view m (View_areas.view m)
  | Shupdofi_clt.Route_page.Area_content _ ->
    View_layout.view m (View_area_content.view m)