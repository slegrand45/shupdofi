module Com = Shupdofi_com

type t = {
  lang : Com.I18n.language option
}

let empty = {
  lang = None
}

let get_lang v =
  v.lang

let set_lang lang _ =
  { lang }
