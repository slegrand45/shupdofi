module S = Tiny_httpd

let accept_encoding enc (req:_ S.Request.t) =
  match
    S.Request.get_header req "Accept-Encoding"
  with
  | Some s -> String.split_on_char ',' s |> List.map String.trim |> List.mem enc
  | None -> false

let can_return_gzip (req:_ S.Request.t) = accept_encoding "gzip" req
let can_return_deflate (req:_ S.Request.t) = accept_encoding "deflate" req

let json s ~code ~req =
  let length = String.length s in
  let resp =
    match length with
    | n when n < 1024 ->
      let () = prerr_endline(Printf.sprintf "< 1024 : %s" s) in
      S.Response.make_string (Ok s) ~code
    | _ ->
      match can_return_deflate req with
      | false ->
        let () = prerr_endline(Printf.sprintf "cannot return deflate : %s" s) in
        S.Response.make_string (Ok s) ~code
      | _ ->
        let zs = Zlib.deflate_init 6 false in
        let size_buf = length + 4096 in
        let buf = Bytes.create size_buf in
        let finished, used_in, used_out = Zlib.deflate_string zs s 0 length buf 0 size_buf Z_FINISH in
        let () = prerr_endline(Printf.sprintf "length:%d finished:%B, used_in:%d, used_out:%d" (String.length s) finished used_in used_out) in
        Zlib.deflate_end zs;
        match finished with
        | true ->
          let s = Bytes.sub_string buf 0 used_out in
          let () = prerr_endline(Printf.sprintf "deflate ok : %s" s) in
          S.Response.make_string (Ok s) ~code
          |> S.Response.set_header "Content-Encoding" "deflate"
        | _ ->
          let () = prerr_endline(Printf.sprintf "deflate not finished : %s" s) in
          S.Response.make_string (Ok s) ~code
  in
  S.Response.set_header "Content-Type" "text/json" resp