let nth l pos =
  if (pos < 0) then
    None
  else
    List.nth_opt l pos

let after_nth l pos =
  List.filteri (fun i _ -> i > pos) l

let from_split_path l =
  let first = nth l 0 in
  match first with
  | Some "areas" -> Page.Areas
  | _ -> (
      match first, nth l 1, nth l 2, nth l 3 with
      | Some "area", Some "content", Some id, None -> Page.Area_content (id, [])
      | Some "area", Some "content", Some id, Some _ ->
        let subdirs = after_nth l 2 |> List.filter (fun e -> e <> "") in
        Page.Area_content (id, subdirs)
      | _ -> Page.Home
    )

let from_pathname pathname =
  let l = String.split_on_char '/' pathname |> List.filter (fun e -> e <> "") in
  from_split_path l
