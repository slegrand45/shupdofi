type t = int64

let from_int64 v = v

let to_int64 v = v

let to_human v =
  let v' = Int64.to_float v in
  let sizes = ["Bytes"; "KB"; "MB"; "GB"; "TB"; "PB"; "EB"; "ZB"; "YB"] in
  let len = List.length sizes in
  let f (x, size) i =
    let i' = Int.to_float i in
    if (size = "" && v' < 1024. ** i') then (
      let x = v' /. (1024. ** (i' -. 1.)) in
      let size = List.nth sizes (i - 1) in
      (x, size)
    ) else (
      (x, size)
    )
  in
  let (x, size) = List.fold_left f (0., "") (List.init len (fun e -> e + 1)) in
  if (size = "Bytes") then
    Printf.sprintf "%.0f %s" x size
  else
    Printf.sprintf "%.1f %s" x size

let from_string s =
  match Int64.of_string_opt s with
  | Some _ as v -> v
  | None ->
    let length = String.length s in
    match length with
    | n when n > 2 -> (
        let u = String.sub s (length - 2) 2 in
        let i = String.sub s 0 (length - 2) in
        match Int64.of_string_opt i with
        | Some i -> (
            match u with
            | "KB" -> Some (Int64.mul i 1024L)
            | "MB" -> Some (Int64.mul i 1_048_576L)
            | "GB" -> Some (Int64.mul i 1_073_741_824L)
            | "TB" -> Some (Int64.mul i 1_099_511_627_776L)
            | "PB" -> Some (Int64.mul i 1_125_899_906_842_624L)
            | _ -> None
          )
        | None -> None
      )
    | _ -> None
