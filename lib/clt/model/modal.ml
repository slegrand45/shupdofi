module Com = Shupdofi_com

type modal =
  | New_entry
  | Confirm_delete
  | Selection_cut_copy

type t = {
  modal : modal option;
  title : string;
  input_content : string;
  input_switch : bool;
  txt_switch : string;
  paste_mode : Com.Path.paste;
  txt_bt_ok : string;
  bt_ok_is_disabled : bool;
  txt_bt_cancel : string;
  fun_bt_ok : Vdom.mouse_event -> Action.t;
  fun_kb_ok : Vdom.key_event -> Action.t;
}

let default = {
  modal = None; 
  title = "";
  input_content = "";
  input_switch = false;
  txt_switch = "";
  paste_mode = Com.Path.Paste_ignore;
  txt_bt_ok = "";
  bt_ok_is_disabled = false;
  txt_bt_cancel = "";
  fun_bt_ok = (fun _ -> Action.Nothing);
  fun_kb_ok = (fun _ -> Action.Nothing);
}

let is_new_entry v =
  match v.modal with
  | Some New_entry -> true
  | _ -> false

let is_confirm_delete v =
  match v.modal with
  | Some Confirm_delete -> true
  | _ -> false

let is_selection_cut_copy v =
  match v.modal with
  | Some Selection_cut_copy -> true
  | _ -> false

let set_new_entry v =
  { v with modal = Some New_entry }

let set_confirm_delete msg v =
  { v with modal = Some Confirm_delete; txt_switch = msg }

let set_selection_cut_copy v =
  { v with modal = Some Selection_cut_copy }

let get_title v = v.title
let get_input_content v = v.input_content
let get_txt_bt_ok v = v.txt_bt_ok
let bt_ok_is_disabled v = v.bt_ok_is_disabled
let bt_ok_is_enabled v = not v.bt_ok_is_disabled
let get_input_switch v = v.input_switch
let get_txt_switch v = v.txt_switch
let get_paste_mode v = v.paste_mode
let get_txt_bt_cancel v = v.txt_bt_cancel
let get_fun_bt_ok v = v.fun_bt_ok
let get_fun_kb_ok v = v.fun_kb_ok

let set_title title v = { v with title }
let set_input_content input_content v = { v with input_content }
let set_txt_bt_ok txt v = { v with txt_bt_ok = txt }
let disable_bt_ok v = { v with bt_ok_is_disabled = true }
let enable_bt_ok v = { v with bt_ok_is_disabled = false }
let set_input_switch switch v = { v with input_switch = switch }
let set_paste_mode mode v = { v with paste_mode = mode }
let toggle_input_switch v = { v with input_switch = not v.input_switch }
let set_txt_bt_cancel txt v = { v with txt_bt_cancel = txt }
let set_fun_bt_ok f v = { v with fun_bt_ok = f }
let set_fun_kb_ok f v = { v with fun_kb_ok = f }
