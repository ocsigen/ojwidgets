

module Make
    (D : Ojw_dom_sigs.T)
    (Button : Ojw_button_sigs.T
     with module D = D)
    (Traversable : Ojw_traversable_sigs.T)
= struct

  module D = D
  module Button = Button
  module Traversable = Traversable

  class type dropdown = object
    inherit Button.button

    method traversable : Traversable.traversable Js.t Js.readonly_prop
  end

  class type dropdown' = object
    inherit dropdown

    method _timeout : unit Lwt.t Js.opt Js.prop
    method _traversable : Traversable.traversable Js.t Js.prop
  end

  let dropdown
        ?(v = `bottom)
        ?(h = `center)
        ?(focus = true)
        ?(hover = false)
        ?(hover_timeout = 1.0)
        ?(enable_link)
        ?(is_traversable)
        ?(predicate)
        ?(on_keydown)
        elt elt_traversable =
    let elt' = (Js.Unsafe.coerce (Button.to_button elt) :> dropdown' Js.t) in

    (* Don't use the 'this' argument because it correspond to dropdown content
     * and not the button used by the dropdown.
     *
     * FIXME: Should we check if 'pressed' method is not undefined ? It should
     * never happen.. *)
    let is_traversable = match is_traversable with
      | None -> (fun _ -> Js.to_bool (elt'##pressed))
      | Some f -> (fun _ -> f (Js.Unsafe.coerce elt'))
    in

    let on_mouseovers, on_mouseouts =
      (fun f ->
         Js.Opt.iter (elt'##_timeout)
           (fun th -> Lwt.cancel th);
         f ()),
      (fun () ->
         let th = Lwt_js.sleep hover_timeout in
         elt'##_timeout <- Js.some th;
         try_lwt
           lwt () = th in
           if (Js.to_bool elt'##pressed) then
             elt'##unpress();
           Lwt.return ()
         with Lwt.Canceled -> Lwt.return ())
    in

    let elt_traversable' = Traversable.D.to_dom_elt elt_traversable in
    let cstyle = Ojw_fun.getComputedStyle elt' in
    elt_traversable'##style##minWidth <- cstyle##width;

    elt'##classList##add(Js.string "ojw_dropdown");

    ignore (
      Button.button_alert ~pressed:false ?predicate elt
        (Button.Alert.D.of_dom_elt elt_traversable')
    );

    Ojw_position.relative_move ~v ~h
      ~relative:(Button.D.to_dom_elt elt)
      elt_traversable';

    elt'##_traversable <-
      Traversable.to_traversable
        (Traversable.traversable
           ?on_keydown ?enable_link ~focus ~is_traversable elt_traversable);

    if hover then begin
      Lwt.async (fun () ->
          Lwt_js_events.mouseovers elt_traversable'
            (fun _ _ ->
               on_mouseovers (fun () -> ());
               Lwt.return ()));

      Lwt.async (fun () ->
          Lwt_js_events.mouseouts elt_traversable'
            (fun _ _ ->
               lwt () = on_mouseouts () in
               Lwt.return ()));
    end;

    elt'##_timeout <- Js.null;

    if hover then begin
      Lwt.async (fun () ->
        Lwt_js_events.mouseovers elt'
          (fun _ _ ->
             on_mouseovers (fun () ->
               if not (Js.to_bool elt'##pressed) then
                 elt'##press()
             );
             Lwt.return ()));

      Lwt.async (fun () ->
        Lwt_js_events.mouseouts elt'
          (fun _ _ ->
             lwt () = on_mouseouts () in
             Lwt.return ()));
    end;

    [
      D.of_dom_elt (Button.D.to_dom_elt elt);
      D.of_dom_elt (Traversable.D.to_dom_elt elt_traversable);
    ]
end
