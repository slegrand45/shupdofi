module Com = Shupdofi_com

(* https://github.com/xavierleroy/camlzip/blob/master/test/minizip.ml *)
let rec add_entry root oc file =
  let entry = file in
  let path = Filename.concat root file in
  let s = Unix.stat path in
  match s.Unix.st_kind with
    Unix.S_REG ->
    Zip.copy_file_to_entry path oc ~mtime:s.Unix.st_mtime entry
  | Unix.S_DIR ->
    Zip.add_entry "" oc ~mtime:s.Unix.st_mtime
      (if Filename.check_suffix file Filename.dir_sep then entry else entry ^ Filename.dir_sep);
    let d = Unix.opendir path in
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
  let path_archive = Path.to_string archive in
  let path_root = Com.Directory.get_name root in
  let path_subdir = Com.Directory.get_name subdir in
  let path_subdir_base = Filename.dirname path_subdir in
  let path_subdir_lastdir = Filename.basename path_subdir in
  let path_root = Filename.concat path_root path_subdir_base in
  create path_archive path_root path_subdir_lastdir