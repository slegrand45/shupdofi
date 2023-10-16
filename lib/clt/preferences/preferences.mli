module Com = Shupdofi_com

type t

val empty : t
val get_lang : t -> Com.I18n.language option
val set_lang : Com.I18n.language option -> t -> t
