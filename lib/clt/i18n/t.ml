module Com = Shupdofi_com
module Prefs = Shupdofi_clt_preferences.Preferences

let _t config token =
  let lang =
    match Prefs.get_lang config with
    | None -> Com.I18n.En
    | Some v -> v
  in
  match lang with
  | Com.I18n.Fr -> T_fr._t token
  | _ -> T_en._t token
