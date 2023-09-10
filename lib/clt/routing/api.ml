type t = Areas
       | Area_content of { area_id: string; subdirs: string list }
       | Upload of { area_id: string; subdirs: string list; filename: string }
       | Download_file of { area_id: string; subdirs: string list; filename: string }
       | Rename_file
       | Delete_file
       | New_directory
       | Download_directory of { area_id: string; subdirs: string list; dirname: string }
       | Rename_directory
       | Delete_directory
       | Delete_selection
       | Download_selection
       | Copy_selection
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
  | Area_content { area_id; subdirs } -> (
      match subdirs with
      | [] ->
        prefix ^ "/area/content/" ^ (encode area_id)
      | l ->
        let s = String.concat "/" l in
        prefix ^ "/area/content/" ^ (encode area_id) ^ "/" ^ s
    )
  | Upload { area_id; subdirs; filename } ->
    let path = List.map (fun e -> encode e) subdirs |> String.concat "/" in
    prefix ^ "/file/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode filename)
  | Download_file { area_id; subdirs; filename } ->
    let path = List.map (fun e -> encode e) subdirs |> String.concat "/" in
    prefix ^ "/file/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode filename)
  | Rename_file ->
    prefix ^ "/file/rename"
  | Delete_file ->
    prefix ^ "/file"
  | New_directory ->
    prefix ^ "/directory"
  | Download_directory { area_id; subdirs; dirname } ->
    let path = List.map (fun e -> encode e) subdirs |> String.concat "/" in
    prefix ^ "/directory/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode dirname)
  | Rename_directory ->
    prefix ^ "/directory/rename"
  | Delete_directory ->
    prefix ^ "/directory"
  | Delete_selection ->
    prefix ^ "/selection"
  | Download_selection ->
    prefix ^ "/selection/download"
  | Copy_selection ->
    prefix ^ "/selection/copy"
  | User ->
    prefix ^ "/user"