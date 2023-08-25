module Com = Shupdofi_com

type language

val user_language : unit -> language
val language_to_string : language -> string
val fmt_date_hm : Com.Datetime.t -> string