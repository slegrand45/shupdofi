type t = Areas
       | Area_content of string * string list
       | Upload of string * string list * string
       | New_directory

let prefix = "/api"

let to_url ?encode v =
  let encode v =
    match encode with
    | None -> v
    | Some f -> f v
  in
  match v with
  | Areas -> prefix ^ "/areas"
  | Area_content (id, subdirs) -> (
      match subdirs with
      | [] ->
        prefix ^ "/area/content/" ^ (encode id)
      | l ->
        let s = String.concat "/" l in
        prefix ^ "/area/content/" ^ (encode id) ^ "/" ^ s
    )
  | Upload (area_id, subdirs, name) ->
    let path = List.map (fun e -> encode e) subdirs |> String.concat "/" in
    prefix ^ "/upload/" ^ (encode area_id) ^ "/" ^ path ^ "/" ^ (encode name)
  | New_directory ->
    prefix ^ "/directory"