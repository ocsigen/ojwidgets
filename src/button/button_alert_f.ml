(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module type In = sig
  include Button_f.In

  type node_t
  type parent_t

  val to_node : node_t -> Dom_html.divElement Js.t
  val to_parent : parent_t -> Dom_html.element Js.t

  val default_parent : unit -> parent_t
end

module Make(M : In) = struct

  class alert
    ?set
    ?(pressed : M.node_t option)
    ?method_closeable
    ?button_closeable
    ?button
    ?(parent_node = M.default_parent ())
    ?(class_ = [])
    ()
    =
  object(self)
    inherit Button.button
           ~pressed:(pressed <> None) ?set
           ?method_closeable
           ?button_closeable
           ?button:(Internals.opt_coerce M.to_button button)
           ()

    val mutable node = None
    val mutable parent_node = M.to_parent parent_node

    method get_node : M.node_t list Lwt.t = Lwt.return []

    method set_parent_node (p : M.parent_t) = parent_node <- (M.to_parent p)

    method on_press =
      lwt n = self#get_node in
      let n = List.map (M.to_node) (n) in
      let d = Dom_html.createDiv Dom_html.document in
      let () =
        List.iter
          (fun cl -> d##classList##add(Js.string cl))
          ("ojw_alert"::class_)
      in
      d##classList##add(Js.string "ojw_pressed");
      let () =
        List.iter
          (fun n -> Dom.appendChild d n)
          (n)
      in
      (Js.Unsafe.coerce d)##o <- self;
      node <- Some d;
      Dom.appendChild parent_node d;
      Lwt.return ()

    method on_unpress =
      let () = match node with
        | None -> ()
        | Some n -> try Dom.removeChild parent_node n with _ -> ()
      in
      Lwt.return ()

    initializer
      match pressed with
        | None -> ()
        | Some n ->
            let n = M.to_node n in
            (Js.Unsafe.coerce n)##o <- self;
            Js.Opt.iter (n##parentNode)
              (fun p ->
                 Js.Opt.iter (Dom_html.CoerceTo.element p)
                   (fun p -> parent_node <- p));
            node <- Some n
  end

end
