module Com = Shupdofi_com

type t = {
  www_root: Com.Directory.absolute Com.Directory.t;
  listen_address: string;
  listen_port: int;
}

let make ~www_root ~listen_address ~listen_port =
  { www_root; listen_address; listen_port }

let to_toml v =
  let fmt s = "\"" ^ (String.escaped s) ^ "\"" in
  Printf.sprintf "[server]\nwww_root = %s\nlisten_address = %s\nlisten_port = %u"
    (fmt (Com.Directory.get_name v.www_root)) (fmt v.listen_address) v.listen_port

let get_www_root v =
  v.www_root

let get_listen_address v =
  v.listen_address

let get_listen_port v =
  v.listen_port
