module Com = Shupdofi_com

val user_language : unit -> Com.I18n.language
val fmt_date_hm : Com.Datetime.t -> string