module Action = Shupdofi_clt_model.Action
module Routing = Shupdofi_clt_routing

val input_file : string -> (string -> 'a) -> 'a Vdom.vdom
val link : Routing.Page.t -> class_attr:string -> title:string -> Action.t Vdom.vdom list -> Action.t Vdom.vdom