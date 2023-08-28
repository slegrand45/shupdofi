type selection = {
  all : bool;
  content : Area_content.t
}

type t = selection option

let empty = None

let to_string = function
  | None -> "empty selection"
  | Some v -> Printf.sprintf "all=%B content=%s" v.all (Area_content.to_string v.content)

let same_location ~area ~subdirs = function
  | Some v ->
    Area_content.get_area v.content |> Area.get_id = Area.get_id area
    && Area_content.get_subdirs v.content = subdirs
  | None -> false

let file ~area ~subdirs file v =
  let already_in_selection e =
    List.exists (fun e -> File.get_name e = File.get_name file) (Area_content.get_files e.content)
  in
  match v, same_location ~area ~subdirs v with
  | Some v, true ->
    let l =
      match already_in_selection v with
      | true -> List.filter (fun e -> File.get_name e <> File.get_name file) (Area_content.get_files v.content)
      | false -> file::(Area_content.get_files v.content)
    in
    Some { all = false; content = (Area_content.set_files l v.content) }
  | _, _ ->
    let content = Area_content.make ~area ~subdirs ~directories:[] ~files:[file] in
    Some { all = false; content }

let directory ~area ~subdirs directory v =
  let already_in_selection e =
    List.exists (fun e -> Directory.get_name e = Directory.get_name directory) (Area_content.get_directories e.content)
  in
  match v, same_location ~area ~subdirs v with
  | Some v, true ->
    let l =
      match already_in_selection v with
      | true -> List.filter (fun e -> Directory.get_name e <> Directory.get_name directory) (Area_content.get_directories v.content)
      | false -> directory::(Area_content.get_directories v.content)
    in
    Some { all = false; content = (Area_content.set_directories l v.content) }
  | _, _ ->
    let content = Area_content.make ~area ~subdirs ~directories:[directory] ~files:[] in
    Some { all = false; content }

let all ~area ~subdirs ~directories ~files v =
  match v, same_location ~area ~subdirs v with
  | Some v, true -> (
      match v.all with
      | true ->
        let content =
          Area_content.set_directories [] v.content |> Area_content.set_files []
        in
        Some { all = false; content }
      | false ->
        let e = { v with content = Area_content.set_directories directories v.content } in
        let e = { v with content = Area_content.set_files files e.content } in
        Some { e with all = true }
    )
  | _, _ ->
    let content = Area_content.make ~area ~subdirs ~directories ~files in
    Some { all = true; content }

let directory_is_selected ~area ~subdirs ~directory v =
  match v, same_location ~area ~subdirs v with
  | Some v, true -> List.exists (fun e -> Directory.get_name e = Directory.get_name directory) (Area_content.get_directories v.content)
  | _, _ -> false

let file_is_selected ~area ~subdirs ~file v =
  match v, same_location ~area ~subdirs v with
  | Some v, true -> List.exists (fun e -> File.get_name e = File.get_name file) (Area_content.get_files v.content)
  | _, _ -> false

let all_is_selected ~area ~subdirs v =
  match v, same_location ~area ~subdirs v with
  | Some v, true -> v.all
  | _, _ -> false

let count = function
  | Some v ->
    (Area_content.get_files v.content |> List.length)
    + (Area_content.get_directories v.content |> List.length)
  | _ -> 0
