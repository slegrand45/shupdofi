type t =
  | Breadcrumb
  | Cancel
  | Clear
  | Copy
  | Copy_it_as_a_new_file_with_an_other_name
  | Copy_paste
  | Copy_selection
  | Create
  | Create_directory of string
  | Cut_paste
  | Delete
  | Delete_directory
  | Delete_directory_name of string
  | Delete_file
  | Delete_file_name of string
  | Delete_selection
  | Directory_created of string
  | Directory_deleted of string
  | Directory_renamed_old_new of (string * string)
  | Download
  | Download_selection
  | File_deleted of string
  | File_renamed_old_new of (string * string)
  | File_uploaded of string
  | Home
  | I_understand_all_selected_directories_files_definitively_deleted_dot
  | I_understand_directory_and_content_will_be_permanently_deleted_dot of string
  | I_understand_file_will_be_permanently_deleted_dot of string
  | Last_modified
  | Move
  | Move_selection
  | Name
  | New_directory
  | Overwrite_it_and_replace_it_with_the_copy
  | Rename
  | Rename_directory
  | Rename_directory_old_new of (string * string)
  | Rename_file
  | Rename_file_old_new of (string * string)
  | Select_all
  | Select_directory
  | Select_file
  | Selection
  | Selection_copied
  | Selection_deleted
  | Selection_moved
  | Silently_ignore_it_and_keep_it_untouched
  | Size
  | Sort_downward
  | Sort_upward
  | Unable_to_copy_selection
  | Unable_to_create_directory of string
  | Unable_to_delete_directory of string
  | Unable_to_delete_file of string
  | Unable_to_delete_selection
  | Unable_to_download_selection
  | Unable_to_move_selection
  | Unable_to_rename_directory_old_new of (string * string)
  | Unable_to_rename_file_old_new of (string * string)
  | Unable_to_upload_file of string
  | Unable_to_upload_file_with_additional_txt of (string * string)
  | Upload
  | Upload_filename of string
  | When_entry_already_exists_colon
