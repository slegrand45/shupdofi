type t = int64

let from_int64 v = v

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
