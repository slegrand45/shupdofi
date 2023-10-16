type t =
  | Breadcrumb
  | Cancel
  | Clear
  | Copy_it_as_a_new_file_with_an_other_name
  | Copy_paste
  | Create
  | Create_directory of string
  | Cut_paste
  | Delete
  | Delete_directory
  | Delete_directory_name of string
  | Delete_file
  | Delete_file_name of string
  | Directory_created of string
  | Directory_deleted of string
  | Directory_renamed_old_new of (string * string)
  | Download
  | File_deleted of string
  | Home
  | I_understand_directory_and_content_will_be_permanently_deleted_dot of string
  | I_understand_file_will_be_permanently_deleted_dot of string
  | Last_modified
  | Name
  | New_directory
  | Overwrite_it_and_replace_it_with_the_copy
  | Rename
  | Rename_directory
  | Rename_directory_old_new of (string * string)
  | Select_all
  | Select_directory
  | Select_file
  | Selection
  | Silently_ignore_it_and_keep_it_untouched
  | Size
  | Sort_downward
  | Sort_upward
  | Unable_to_create_directory of string
  | Unable_to_delete_directory of string
  | Unable_to_delete_file of string
  | Upload
  | When_entry_already_exists_colon
