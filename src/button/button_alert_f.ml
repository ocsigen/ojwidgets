(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module type In = sig
  include Button_f.In

  type node_t
  type parent_t

  val of_node : Dom_html.divElement Js.t -> node_t
  val to_node : node_t -> Dom_html.divElement Js.t
  val to_parent : parent_t -> Dom_html.element Js.t

  val default_parent : unit -> parent_t
end

module Make(M : In) = struct

  class alert
    ?set
    ?(allow_outer_click = false)
    ?(pressed : M.node_t option)
    ?closeable_by_method
    ?closeable_by_button
    ?button
    ?(parent_node = M.default_parent ())
    ?(class_ = [])
    ()
    =
  object(self)
    inherit Button.button
           ~pressed:(pressed <> None) ?set
           ?closeable_by_method
           ?closeable_by_button
           ?button:(Internals.opt_coerce M.to_button button)
           ()

    val mutable node = None
    val mutable parent_node = M.to_parent parent_node

    method get_node : M.node_t list Lwt.t = Lwt.return []

    method get_alert_box : M.node_t option =
      match node with
        | None -> None
        | Some n -> Some (M.of_node n)

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
      (* Are the handlers remove if the element to which they are
       * attached is removed too ? If not, this part of the code
       * should be optimized and maybe re-think. *)
      let () =
        if not allow_outer_click then
          Lwt.async
            (fun () ->
               Lwt_js_events.clicks (d)
                 (fun e _ ->
                    Dom_html.stopPropagation e;
                    Lwt.return ()));
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
      node <- None;
      Lwt.return ()

    initializer
      let () =
        if not allow_outer_click then
          Lwt.async
            (fun () ->
               Lwt_js_events.clicks (Dom_html.document##body)
                 (fun e _ ->
                    if not self#pressed
                    then Lwt.return ()
                    else
                      (lwt () = self#unpress in
                       Dom.preventDefault e;
                       Dom_html.stopPropagation e;
                       Lwt.return ())))
      in
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
