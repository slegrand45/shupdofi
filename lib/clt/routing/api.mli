type t = Areas
       | Area_content of { area_id: string; subdirs: string list }
       | Upload of { area_id: string; subdirs: string list; filename: string }
       | Download_file of { area_id: string; subdirs: string list; filename: string }
       | Rename_file
       | Delete_file
       | New_directory
       | Download_directory of { area_id: string; subdirs: string list; dirname: string }
       | Rename_directory
       | Delete_directory
       | Delete_selection
       | Download_selection
       | Copy_selection
       | User

val to_url : ?encode:(string -> string) -> t -> string
