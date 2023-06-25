module Com = Shupdofi_com

type t = Com.File.t

let is_without_parent_dir_name s =
  let r = Str.regexp_string ".." in
  not (Str.string_match r s 0)

let remove_sep_first s =
  if (String.starts_with ~prefix:Filename.dir_sep s) then (
    String.sub s 1 ((String.length s) - 1)
  ) else s

let add_extension ext v =
  (* supprimer les . dans ext *)
  let s = Filename.extension ("test." ^ ext) in
  Com.File.set_name ((Com.File.get_name v) ^ s) v
