let nth l pos =
  if (pos < 0) then
    None
  else
    List.nth_opt l pos

let after_nth l pos =
  List.filteri (fun i v -> i > pos) l

let from_split_path l =
  let first = nth l 0 in
  let second = nth l 1 in
  let third = nth l 2 in
  let fourth = nth l 3 in
  match first with
  | Some "areas" -> Route_page.Areas
  | _ -> (
      match first, second, third, fourth with
      | Some "area", Some "content", Some id, None -> Route_page.Area_content (id, [])
      | Some "area", Some "content", Some id, Some s ->
        let subdirs = after_nth l 2 |> List.filter (fun e -> e <> "") in
        Route_page.Area_content (id, subdirs)
      | _ -> Route_page.Home
    )

let from_pathname pathname =
  let l = String.split_on_char '/' pathname |> List.filter (fun e -> e <> "") in
  from_split_path l
