type t = Areas
       | Area_content of string * string list
       | Upload of string * string list * string

val to_url : ?encode:(string -> string) -> t -> string
