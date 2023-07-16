type section = Section_user | Section_admin
(* A MODIFIER ? : correspond en fait aux routes ? *)
type page = Areas | Area of string

type t = (section * page)
