module Com = Shupdofi_com

type t = Com.Area.t
type collection = t list

let get_all () =
  (* TODO: return root only if user have access right *)
  [
    Com.Area.make ~id:"area1" ~name:"name1" ~description:"description1" ~root:(Com.Directory.make ~name:"/tmp/test-shupdofi/area1" ());
    Com.Area.make ~id:"area2" ~name:"name2" ~description:"description2" ~root:(Com.Directory.make ~name:"/tmp/test-shupdofi/area2" ());
    Com.Area.make ~id:"area3" ~name:"name3" ~description:"description3" ~root:(Com.Directory.make ~name:"/tmp/test-shupdofi/area3" ());
  ]

let get_content ~id ~subdirs =
  let area = List.find_opt (fun e -> Com.Area.get_id e = id) (get_all ()) in
  match area with
  | None -> Com.Area_content.make ~id:"" ~subdirs ~directories:[] ~files:[] 
  | Some area ->
    let dir = Directory.concat (Com.Area.get_root area) (Directory.make_from_list subdirs) in
    let (directories, files) = Directory.read dir in
    Com.Area_content.make ~id ~subdirs ~directories ~files 