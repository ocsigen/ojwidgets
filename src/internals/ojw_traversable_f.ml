

module Make(D : Ojw_dom_sigs.Opt ) = struct

  module D = D

  class type traversable = object
    inherit Ojw_base_widget.widget

    method getContainer : D.element D.elt  Js.meth

    method next : unit Js.meth
    method prev : unit Js.meth
    method resetActive : unit Js.meth
    method setActive : D.element D.elt -> unit Js.meth
    method getActive : D.element D.elt D.opt Js.meth
    method isTraversable : bool Js.meth
  end

  class type traversable' = object
    inherit traversable
    inherit Ojw_base_widget.widget'

    method _getContainer : (#traversable Js.t, unit -> D.element D.elt) Js.meth_callback Js.prop

    method _next : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _prev : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _resetActive : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _setActive : (#traversable Js.t, D.element D.elt -> unit) Js.meth_callback Js.prop
    method _getActive : (#traversable Js.t, unit -> D.element D.elt D.opt) Js.meth_callback Js.prop
    method _isTraversable : (#traversable Js.t, unit -> bool) Js.meth_callback Js.prop
  end

  let default_is_traversable this =
    let elt =
      this##querySelector
        (Js.string "li[data-value].ew_dropdown_element > a:focus")
    in
    Js.Opt.case (elt)
      (fun () -> false)
      (fun _  -> true)

  let default_on_keydown _ =
    false

  let traversable
        ?(enable_link = true)
        ?(focus = true)
        ?(is_traversable = default_is_traversable)
        ?(on_keydown = default_on_keydown)
        elt =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) :> traversable' Js.t) in
    let meth = Js.wrap_meth_callback in

    ignore (Ojw_base_widget.ctor elt' "traversable");

    let contains elt cl =
      elt##classList##contains(Js.string cl) = Js._true
    in

    let move ~default ~next this =
      let set item = this##setActive(D.of_dom_elt (Js.Unsafe.coerce item)) in
      D.opt_case (this##getActive())
        (fun () ->
           D.opt_iter (D.to_opt (default ())) (fun item -> set item))
        (fun active ->
           let rec aux item =
             Js.Opt.case (next item)
               (fun () ->
                  Js.Opt.iter (default ()) (fun item -> set item))
               (fun item ->
                  let item = (Js.Unsafe.coerce item :> Dom_html.element Js.t) in
                  if contains item "ew_dropdown_element"
                  then (
                    Js.Opt.iter (item##getAttribute(Js.string "data-value"))
                      (fun attr ->
                         Ojw_log.log (Js.to_string attr));
                    set item
                  )
                  else aux item)
           in aux (D.to_dom_elt active))
    in

    elt'##_getContainer <-
    meth (fun this () ->
      elt
    );

    elt'##_prev <-
    meth (fun this () ->
      move this
        ~default:(fun () -> elt'##lastChild)
        ~next:(fun elt -> Ojw_log.log "prevSibling"; elt##previousSibling)
    );

    elt'##_next <-
    meth (fun this () ->
      move this
        ~default:(fun () -> elt'##firstChild)
        ~next:(fun elt -> Ojw_log.log "nextSibling"; elt##nextSibling)
    );

    let (!$) q = elt'##querySelector(Js.string q) in

    elt'##_resetActive <-
    meth (fun this () ->
      D.opt_iter (this##getActive())
        (fun item ->
           (D.to_dom_elt item)##classList##remove(Js.string "selected"));
    );

    elt'##_getActive <-
    meth (fun this () ->
      Js.Opt.case (!$ "li[data-value].ew_dropdown_element.selected")
        (fun () -> D.opt_none)
        (fun item -> D.opt_some (D.of_dom_elt item))
    );

    elt'##_setActive <-
    meth (fun this item ->
      Js.Opt.case ((D.to_dom_elt item)##parentNode)
        (* if there is no parent, so item is not a child of
         * the traversable element *)
        (fun () -> ())
        (fun parent ->
           if not (parent = ((D.to_dom_elt elt) :> Dom.node Js.t))
           then ()
           else (
             D.opt_iter (this##getActive())
               (fun item ->
                  (D.to_dom_elt item)##classList##remove(Js.string "selected"));
             (D.to_dom_elt item)##classList##add(Js.string "selected");
             if focus then
               Js.Opt.iter ((D.to_dom_elt item)##firstChild)
                 (fun item -> (Js.Unsafe.coerce item)##focus());
             ()))
    );

    elt'##_isTraversable <-
    meth (fun this () ->
      is_traversable this
    );

    Ojw_log.log "event_listener: keydown";
    Lwt.async (fun () ->
      Lwt_js_events.keydowns Dom_html.document
        (fun e _ ->
           Ojw_log.log "keydown";
           if elt'##isTraversable() then begin
             let prevent = ref false in
             (match e##keyCode with
              | 38 -> (* up *)
                  elt'##prev(); prevent := true;
              | 40 -> (* down *)
                  elt'##next(); prevent := true;
              | _ ->
                  prevent := (on_keydown e));
             if !prevent then Dom.preventDefault e
           end;
           Lwt.return ()
        ));

    let is_child_of child parent =
      (parent##compareDocumentPosition(child) land 16) = 16
    in
    Lwt.async (fun () ->
      Lwt_js_events.clicks elt'
        (fun e _ ->
           (Js.Optdef.iter (e##toElement) (fun elt ->
              Js.Opt.iter elt
                (fun elt ->
                   let rec aux it =
                     Js.Opt.iter (Dom_html.CoerceTo.element it)
                       (fun elt ->
                          if not (contains elt "ew_dropdown") then begin
                            if not (contains elt "ew_dropdown_element")
                            then (Js.Opt.iter (elt##parentNode) (fun p -> aux p))
                            else (
                              elt'##setActive (D.of_dom_elt elt);
                              if not enable_link
                              then Dom.preventDefault e
                              else (()))
                          end)
                   in
                   if is_child_of (elt :> Dom.node Js.t) elt'
                   then aux (elt :> Dom.node Js.t))));
           Lwt.return ()));

    elt

  let to_traversable elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> traversable Js.t)
end
