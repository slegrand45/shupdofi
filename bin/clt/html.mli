val input_file : string -> (string -> 'a) -> 'a Vdom.vdom
val link : Shupdofi_clt.Route_page.t -> class_attr:string -> title:string -> Action.t Vdom.vdom list -> Action.t Vdom.vdom