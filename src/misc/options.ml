let (>>=) = Lwt.bind

let map_option f v =
  match v with
    | None -> None
    | Some a -> Some (f a)

let map_option_lwt f v =
  match v with
    | None -> Lwt.return None
    | Some a -> f a >>= fun r -> Lwt.return (Some r)

let apply_option f v =
  match v with
    | None -> ()
    | Some a -> f a

let apply_option_lwt f v =
  match v with
    | None -> Lwt.return ()
    | Some a -> f a

let lwt_map t f g =
  match Lwt.state t with
    | Lwt.Return v -> f v
    | _ -> g ()

module List = struct

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
end

external id : 'a -> 'a = "%identity"

let of_opt elt =
  Js.Opt.case elt (fun () -> failwith "of_opt") (fun elt -> elt)
