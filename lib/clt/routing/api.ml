type t = Areas
       | Area_content of { area_id: string; area_subdirs: string list }
       | Upload of { area_id: string; area_subdirs: string list; filename: string }
       | Download_file of { area_id: string; area_subdirs: string list; filename: string }
       | Rename_file
       | Delete_file
       | New_directory
       | Download_directory of { area_id: string; area_subdirs: string list; dirname: string }
       | Rename_directory
       | Delete_directory
       | User

let prefix = "/api"

let to_url ?encode v =
  let encode v =
    match encode with
    | None -> v
    | Some f -> f v
  in
  match v with
  | Areas -> prefix ^ "/areas"
  | Area_content { area_id; area_subdirs } -> (
      match area_subdirs with
      | [] ->
        prefix ^ "/area/content/" ^ (encode area_id)
      | l ->
        let s = String.concat "/" l in
        prefix ^ "/area/content/" ^ (encode area_id) ^ "/" ^ s
    )
  | Upload { area_id; area_subdirs; filename } ->
    let path = List.map (fun e -> encode e) area_subdirs |> String.concat "/" in
    prefix ^ "/file/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode filename)
  | Download_file { area_id; area_subdirs; filename } ->
    let path = List.map (fun e -> encode e) area_subdirs |> String.concat "/" in
    prefix ^ "/file/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode filename)
  | Rename_file ->
    prefix ^ "/file/rename"
  | Delete_file ->
    prefix ^ "/file"
  | New_directory ->
    prefix ^ "/directory"
  | Download_directory { area_id; area_subdirs; dirname } ->
    let path = List.map (fun e -> encode e) area_subdirs |> String.concat "/" in
    prefix ^ "/directory/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode dirname)
  | Rename_directory ->
    prefix ^ "/directory/rename"
  | Delete_directory ->
    prefix ^ "/directory"
  | User ->
    prefix ^ "/user"