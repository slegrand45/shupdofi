type t = {
  all : bool;
  content : Area_content.t
}

let empty = []

let to_string v =
  let f acc e =
    (Printf.sprintf "all=%B content=%s" e.all (Area_content.to_string e.content)) :: acc
  in
  List.fold_left f [] v |> List.rev |> String.concat "\n"

let same_area_and_subdirs area subdirs e =
  Area_content.get_area e.content |> Area.get_id = Area.get_id area
  && Area_content.get_subdirs e.content = subdirs

let file ~area ~subdirs file v =
  let already_in_selection e =
    List.exists (fun e -> File.get_name e = File.get_name file) (Area_content.get_files e.content)
  in
  match List.exists (same_area_and_subdirs area subdirs) v with
  | true ->
    let f e =
      match same_area_and_subdirs area subdirs e with
      | true ->
        let l =
          match already_in_selection e with
          | true -> List.filter (fun e -> File.get_name e <> File.get_name file) (Area_content.get_files e.content)
          | false -> file::(Area_content.get_files e.content)
        in
        { all = false; content = (Area_content.set_files l e.content) }
      | false ->
        { e with all = false }
    in
    List.map f v
  | false ->
    let content = Area_content.make ~area ~subdirs ~directories:[] ~files:[file] in
    { all = false; content } :: v

let directory ~area ~subdirs directory v =
  let already_in_selection e =
    List.exists (fun e -> Directory.get_name e = Directory.get_name directory) (Area_content.get_directories e.content)
  in
  match List.exists (same_area_and_subdirs area subdirs) v with
  | true ->
    let f e =
      match same_area_and_subdirs area subdirs e with
      | true ->
        let l =
          match already_in_selection e with
          | true -> List.filter (fun e -> Directory.get_name e <> Directory.get_name directory) (Area_content.get_directories e.content)
          | false -> directory::(Area_content.get_directories e.content)
        in
        { all = false; content = (Area_content.set_directories l e.content) }
      | false ->
        { e with all = false }
    in
    List.map f v
  | false ->
    let content = Area_content.make ~area ~subdirs ~directories:[directory] ~files:[] in
    { all = false; content } :: v

let all ~area ~subdirs ~directories ~files v =
  match List.exists (same_area_and_subdirs area subdirs) v with
  | true ->
    let f e =
      match same_area_and_subdirs area subdirs e with
      | true -> (
          match e.all with
          | true ->
            let content =
              Area_content.set_directories [] e.content |> Area_content.set_files []
            in
            { all = false; content }
          | false ->
            let e = { e with content = Area_content.set_directories directories e.content } in
            let e = { e with content = Area_content.set_files files e.content } in
            { e with all = true }
        )
      | false -> e
    in
    List.map f v
  | false ->
    let content = Area_content.make ~area ~subdirs ~directories ~files in
    { all = true; content } :: v

let directory_is_selected ~area ~subdirs ~directory v =
  let f e =
    List.exists (fun e -> Directory.get_name e = Directory.get_name directory) (Area_content.get_directories e.content)
  in
  List.exists (fun e -> f e && same_area_and_subdirs area subdirs e) v

let file_is_selected ~area ~subdirs ~file v =
  let f e =
    List.exists (fun e -> File.get_name e = File.get_name file) (Area_content.get_files e.content)
  in
  List.exists (fun e -> f e && same_area_and_subdirs area subdirs e) v

let all_is_selected ~area ~subdirs v =
  List.exists (fun e -> e.all && same_area_and_subdirs area subdirs e) v