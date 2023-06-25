module Com = Shupdofi_com

type t = {
  www_root: Com.Directory.t;
}

let make ~www_root =
  { www_root }

let get_www_root v =
  v.www_root