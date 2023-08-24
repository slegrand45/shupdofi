module Com = Shupdofi_com

type t =
  | Clear of { area : Com.Area.t; subdirs : string list }