module Com = Shupdofi_com_com

type language

val user_language : unit -> language
val language_to_string : language -> string
val fmt_date_hm : language -> Com.Datetime.t -> string