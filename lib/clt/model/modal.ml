type t = {
  title : string;
  input_content : string;
  txt_bt_ok : string;
  txt_bt_cancel : string;
  fun_bt_ok : Vdom.mouse_event -> Action.t;
}

let default = {
  title = "";
  input_content = "";
  txt_bt_ok = "";
  txt_bt_cancel = "";
  fun_bt_ok = fun _ -> Action.Nothing;
}

let get_title v = v.title
let get_input_content v = v.input_content
let get_txt_bt_ok v = v.txt_bt_ok
let get_txt_bt_cancel v = v.txt_bt_cancel
let get_fun_bt_ok v = v.fun_bt_ok

let set_title title v = { v with title }
let set_input_content input_content v = { v with input_content }
let set_txt_bt_ok txt v = { v with txt_bt_ok = txt }
let set_txt_bt_cancel txt v = { v with txt_bt_cancel = txt }
let set_fun_bt_ok f v = { v with fun_bt_ok = f }
