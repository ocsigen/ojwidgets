
external id : 'a -> 'a = "%identity"

let of_opt elt =
  Js.Opt.case elt (fun () -> failwith "of_opt") id

let subs_suffix s n = String.sub s 0 ((String.length s) - n)

let int_of_pxstring px =
  if not (String.length (Js.to_string px) > 2) then 0
  else
    (match (Js.to_string px) with
       | s when s = (subs_suffix s 2)^"px" ->
           int_of_float (float_of_string (subs_suffix s 2))
       | _ -> 0 (* raise exception ? *))

let pxstring_of_int px =
  Js.string ((string_of_int px)^"px")
