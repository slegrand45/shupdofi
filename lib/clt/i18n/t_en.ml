open T_token

let _t = function
  | Breadcrumb -> "Breadcrumb"
  | Cancel -> "Cancel"
  | Clear -> "Clear"
  | Copy_it_as_a_new_file_with_an_other_name -> "Copy it as a new entry with an other name"
  | Copy_paste -> "Copy & paste"
  | Create -> "Create"
  | Create_directory dirname ->
    Printf.sprintf "Create directory %s" dirname
  | Cut_paste -> "Cut & paste"
  | Delete -> "Delete"
  | Delete_directory -> "Delete directory"
  | Delete_directory_name dirname ->
    Printf.sprintf "Delete directory %s" dirname
  | Delete_file -> "Delete file"
  | Delete_file_name filename ->
    Printf.sprintf "Delete file %s" filename
  | Directory_created dirname ->
    Printf.sprintf "Directory %s created" dirname
  | Directory_deleted dirname ->
    Printf.sprintf "Directory %s deleted" dirname
  | Directory_renamed_old_new (oldname, newname) ->
    Printf.sprintf "Directory %s renamed to %s" oldname newname
  | Download -> "Download"
  | File_deleted filename ->
    Printf.sprintf "File %s deleted" filename
  | Home -> "Home"
  | I_understand_directory_and_content_will_be_permanently_deleted_dot dirname ->
    Printf.sprintf "I understand that the directory \"%s\" and all its contents will be permanently deleted." dirname
  | I_understand_file_will_be_permanently_deleted_dot filename ->
    Printf.sprintf "I understand that the file \"%s\" will be permanently deleted." filename
  | Last_modified -> "Last modified"
  | Name -> "Name"
  | New_directory -> "New directory"
  | Overwrite_it_and_replace_it_with_the_copy -> "Overwrite it and replace it with the copy"
  | Rename -> "Rename"
  | Rename_directory -> "Rename directory"
  | Rename_directory_old_new (oldname, newname) ->
    Printf.sprintf "Rename directory %s to %s" oldname newname
  | Select_all -> "Select all"
  | Select_directory -> "Select directory"
  | Select_file -> "Select file"
  | Selection -> "Selection"
  | Silently_ignore_it_and_keep_it_untouched -> "Silently ignore it and keep it untouched"
  | Size -> "Size"
  | Sort_upward -> "Sort upward"
  | Sort_downward -> "Sort downward"
  | Unable_to_create_directory dirname ->
    Printf.sprintf "Unable to create directory %s" dirname
  | Unable_to_delete_directory dirname ->
    Printf.sprintf "Unable to delete directory %s" dirname
  | Unable_to_delete_file filename ->
    Printf.sprintf "Unable to delete file %s" filename
  | Upload -> "Upload"
  | When_entry_already_exists_colon -> "When an entry already exists:"