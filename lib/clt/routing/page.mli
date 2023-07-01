type t = Home
       | Area_content of string * string list
       | Areas

val to_url : ?encode:(string -> string) -> t -> string
