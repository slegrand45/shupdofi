module Routing = Shupdofi_clt_routing

val input_file : string -> (string -> Shupdofi_clt_model.Action.t) -> Shupdofi_clt_model.Action.t Vdom.vdom
val link : Routing.Page.t -> class_attr:string -> title:string -> Shupdofi_clt_model.Action.t Vdom.vdom list -> Shupdofi_clt_model.Action.t Vdom.vdom