module Com = Shupdofi_com

type t = Com.File.t

let add_extension ext v =
  (* supprimer les . dans ext *)
  let s = Filename.extension ("test." ^ ext) in
  Com.File.set_name ((Com.File.get_name v) ^ s) v
