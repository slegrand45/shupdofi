module Com = Shupdofi_com

(* https://github.com/xavierleroy/camlzip/blob/master/test/minizip.ml *)
let rec add_entry root oc file =
  let entry = String.sub file (String.length root) ((String.length file) - (String.length root)) in
  let entry = (if (String.sub entry 0 1) = Filename.dir_sep then (String.sub entry 1 ((String.length entry) - 1)) else entry) in
  let s = Unix.stat file in
  match s.Unix.st_kind with
    Unix.S_REG ->
    Zip.copy_file_to_entry file oc ~mtime:s.Unix.st_mtime entry
  | Unix.S_DIR ->
    Zip.add_entry "" oc ~mtime:s.Unix.st_mtime
      (if Filename.check_suffix file Filename.dir_sep then entry else entry ^ Filename.dir_sep);
    let d = Unix.opendir file in
    begin try
        while true do
          let e = Unix.readdir d in
          if e <> "." && e <> ".." then add_entry root oc (Filename.concat file e)
        done
      with End_of_file -> ()
    end;
    Unix.closedir d
  | _ -> ()  

(* https://github.com/xavierleroy/camlzip/blob/master/test/minizip.ml *)
let create zipfile root directory =
  let oc = Zip.open_out zipfile in
  add_entry root oc directory;
  Zip.close_out oc

let create_archive_of_directory ~archive ~root ~subdir =
  let path_dir = Directory.concat root subdir in
  let path_archive = Path.to_string archive in
  create path_archive (Com.Directory.get_name root) (Com.Directory.get_name path_dir)