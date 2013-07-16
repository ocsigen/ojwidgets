(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

let opt_coerce f = function
  | None -> None
  | Some a -> Some (f a)
