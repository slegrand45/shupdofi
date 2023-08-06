module Com = Shupdofi_com
module Config = Shupdofi_srv_config

type t = Com.Area.t
type collection = t list

let get_content config ~id ~subdirs =
  let area = List.find_opt (fun e -> Config.Area.get_area_id e = id) (Config.Config.get_areas config) in
  match area with
  | None -> Com.Area_content.make ~id:"" ~subdirs ~directories:[] ~files:[] 
  | Some area ->
    let dir = Directory.concat (Config.Area.get_root area) (Directory.make_from_list subdirs) in
    let (directories, files) = Directory.read dir in
    Com.Area_content.make ~id ~subdirs ~directories ~files 