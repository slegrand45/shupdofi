type t = Areas
       | Area_content of { area_id: string; area_subdirs: string list }
       | Upload of { area_id: string; area_subdirs: string list; filename: string }
       | Download of { area_id: string; area_subdirs: string list; filename: string }
       | New_directory

val to_url : ?encode:(string -> string) -> t -> string
