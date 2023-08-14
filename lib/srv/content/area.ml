module Com = Shupdofi_com
module Config = Shupdofi_srv_config

type t = Com.Area.t
type collection = t list

let get_content config ~area ~subdirs =
  let dir = Directory.concat (Config.Area.get_root area) (Directory.make_from_list subdirs) in
  let (directories, files) = Directory.read dir in
  let area = Config.Area.get_area area in
  Com.Area_content.make ~area ~subdirs ~directories ~files