type t = {
  title : string;
  content : string;
  txt_bt_ok : string;
  txt_bt_cancel : string;
}

let default = {
  title = "";
  content = "";
  txt_bt_ok = "";
  txt_bt_cancel = "";
}

let get_title v = v.title
let get_content v = v.content
let get_txt_bt_ok v = v.txt_bt_ok
let get_txt_bt_cancel v = v.txt_bt_cancel

let set_title title v = { v with title }
let set_content content v = { v with content }
let set_txt_bt_ok txt v = { v with txt_bt_ok = txt }
let set_txt_bt_cancel txt v = { v with txt_bt_cancel = txt }
