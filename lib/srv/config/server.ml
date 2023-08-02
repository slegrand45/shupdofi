module Com = Shupdofi_com

type t = {
  www_root: Com.Directory.absolute Com.Directory.t;
}

let make ~www_root =
  { www_root }

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  Printf.sprintf "[server]\nwww_root = %s" (fmt (Com.Directory.get_name v.www_root))

let get_www_root v =
  v.www_root