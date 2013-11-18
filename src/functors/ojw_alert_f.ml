open Dom
open Dom_html

module Make(M : sig
  type parent'
  type container'
  type container_content'

  val to_parent : parent' -> element Js.t
  val to_container : container' -> element Js.t

  val of_container : element Js.t -> container'

  val default_parent : unit -> parent'
  val default_container : container_content' list -> container'
end) = struct
  exception Close_during_initialization

  type t' = {
    parent : element Js.t;
    container : element Js.t;
  }

  type t = t' option ref

  let closed t = (!t = None)

  let close t =
    match !t with
      | Some t -> removeChild t.parent t.container;
      | None -> raise Close_during_initialization

  let alert ?parent ?wrap ?before ?after f =
    let p = match parent with
      | None ->
          (fun () -> M.to_parent (M.default_parent ()))
      | Some p ->
          (fun () -> M.to_parent p)
    in
    let c = match wrap with
      | Some c ->
          (fun cnt -> M.to_container (c cnt))
      | None ->
          (fun cnt -> M.to_container (M.default_container cnt))
    in
    let alrt = ref None in
    let p = p () in
    let c = c (f alrt) in
    alrt := Some {
      parent = p;
      container = c;
    };
    (match before with
       | None -> ()
       | Some f -> Ojw_tools.as_dom_elt c (fun c -> f (M.of_container c)));
    appendChild p c;
    (match after with
       | None -> ()
       | Some f -> f (M.of_container c));
    alrt
end
