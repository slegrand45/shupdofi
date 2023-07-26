type t =  
  | Start of { input_file_id : string }
  | Do of { area_id : string; area_subdirs : string list; toast_id : string; file : Js_browser.File.t }
  | Done of { toast_id : string; status : int; json : string; filename : string }