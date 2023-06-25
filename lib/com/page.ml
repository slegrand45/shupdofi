type section = Section_user | Section_admin
(* correspond aux routes *)
type page = Areas | Area of string

type t = (section * page)
