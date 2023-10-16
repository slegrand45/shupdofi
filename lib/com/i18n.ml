type language = En | Fr

let language_from_string = function
  | "fr" -> Fr
  | _ -> En

let language_to_string = function
  | Fr -> "fr"
  | En -> "en"
