let map f v =
  match v with
    | None -> None
    | Some a -> Some (f a)

let map_lwt f v =
  match v with
    | None -> Lwt.return None
    | Some a -> Lwt.bind (f a) (fun r -> Lwt.return (Some r))

let iter f v =
  match v with
    | None -> ()
    | Some a -> f a

let iter_lwt f v =
  match v with
    | None -> Lwt.return ()
    | Some a -> f a

let lwt_map t f g =
  match Lwt.state t with
    | Lwt.Return v -> f v
    | _ -> g ()
