
include List

let rec find_remove f = function
  | [] -> raise Not_found
  | a::l when f a -> a, l
  | a::l -> let b, ll = find_remove f l in b, a::ll

let rec assoc_remove x = function
  | [] -> raise Not_found
  | (k, v)::l when x = k -> v, l
  | a::l -> let b, ll = assoc_remove x l in b, a::ll

(* remove duplicates in a sorted list *)
let uniq =
  let rec aux last = function
    | [] -> []
    | a::l when a = last -> aux a l
    | a::l -> a::(aux a l)
  in
  function
    | [] -> []
    | a::l -> a::(aux a l)
