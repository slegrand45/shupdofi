type t = Home
       | Area_content of string * string list
       | Areas

let to_url ?encode v =
  let encode v =
    match encode with
    | None -> v
    | Some f -> f v
  in
  match v with
  | Home -> "/"
  | Areas -> "/areas"
  | Area_content (id, subdirs) ->
    match subdirs with
    | [] ->
      "/area/content/" ^ (encode id)
    | l ->
      let s = List.map (fun e -> encode e) l |> String.concat "/" in
      "/area/content/" ^ (encode id) ^ "/" ^ s