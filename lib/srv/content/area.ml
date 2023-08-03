module Com = Shupdofi_com
module Config = Shupdofi_srv_config

type t = Com.Area.t
type collection = t list

let get_all config =
  (* For now, this function is used only to send the areas list to the client.
     So the root value must not (and doesn't need to) be set.

     TODO: return root only if user have access right
      (* ~root:(Com.Directory.make_absolute ~name:"..." ()) *)
  *)
  let areas = Config.Config.get_areas config in
  List.map (Com.Area.set_root (Com.Directory.make_absolute ~name:"" ())) areas

let get_content config ~id ~subdirs =
  let area = List.find_opt (fun e -> Com.Area.get_id e = id) (Config.Config.get_areas config) in
  match area with
  | None -> Com.Area_content.make ~id:"" ~subdirs ~directories:[] ~files:[] 
  | Some area ->
    let dir = Directory.concat (Com.Area.get_root area) (Directory.make_from_list subdirs) in
    let (directories, files) = Directory.read dir in
    Com.Area_content.make ~id ~subdirs ~directories ~files 