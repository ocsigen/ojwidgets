

module Make
    (D : Ojw_dom_sigs.T)
    (Content : Ojw_dom_sigs.T)
= struct

  module D = D
  module Content = Content

  type by = [
      | `Click
      | `Key of int
      | `Explicit
  ]

  class type traversable = object
    inherit Ojw_base_widget.widget

    method getContainer : D.element D.elt  Js.meth

    method next : unit Js.meth
    method prev : unit Js.meth
    method resetActive : unit Js.meth
    method setActive : Content.element Content.elt -> unit Js.meth
    method getActive : Content.element Content.elt Js.opt Js.meth
    method isTraversable : bool Js.meth
  end

  class type traversable' = object
    inherit traversable
    inherit Ojw_base_widget.widget'

    method _getContainer : (#traversable Js.t, unit -> D.element D.elt) Js.meth_callback Js.prop

    method _next : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _prev : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _resetActive : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _setActive : (#traversable Js.t, Content.element Content.elt -> unit) Js.meth_callback Js.prop
    method _getActive : (#traversable Js.t, unit -> Content.element Content.elt Js.opt) Js.meth_callback Js.prop
    method _isTraversable : (#traversable Js.t, unit -> bool) Js.meth_callback Js.prop

    method _setActiveBy : (#traversable Js.t, by -> Content.element Content.elt -> unit) Js.meth_callback Js.prop
    method setActiveBy : by -> Content.element Content.elt -> unit Js.meth
  end

  class type traversable_detail_event = object
    method by : by Js.meth
  end

  class type traversable_event = object
    inherit [traversable_detail_event] Ojw_event.customEvent
  end

  class type traversable_detail_event' = object
    method _by : (#traversable_event Js.t, unit -> by) Js.meth_callback Js.prop
  end

  module Event = struct
    type event = traversable_event Js.t Dom.Event.typ

    module S = struct (* Single *)
      let active = "active"
    end
    let actives : event = Dom.Event.make S.active
  end

  let active ?use_capture target =
    Lwt_js_events.make_event Event.actives ?use_capture target
  let actives ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop active ?cancel_handler ?use_capture (D.to_dom_elt t)

  module Style = struct
    let traversable_cls = "ojw_traversable"
    let traversable_elt_cls = "ojw_traversable_elt"
    let selected_cls = "selected"
  end

  let default_is_traversable this =
    let elt =
      this##querySelector
        (Js.string (Printf.sprintf "li.%s > a:focus" Style.traversable_cls))
    in
    Js.Opt.case (elt)
      (fun () -> false)
      (fun _  -> true)

  let default_on_keydown _ =
    Lwt.return false

  let traversable
        ?(enable_link = true)
        ?(focus = true)
        ?(is_traversable = default_is_traversable)
        ?(on_keydown = default_on_keydown)
        elt =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) :> traversable' Js.t) in
    let meth = Js.wrap_meth_callback in

    elt'##classList##add(Js.string Style.traversable_cls);

    ignore (Ojw_base_widget.ctor elt' "traversable");

    let contains elt cl =
      elt##classList##contains(Js.string cl) = Js._true
    in

    let move ~default ~next this =
      let set item = this##setActive(Content.of_dom_elt (Js.Unsafe.coerce item)) in
      Js.Opt.case (this##getActive())
        (fun () ->
           Js.Opt.iter (default ()) (fun item -> set item))
        (fun active ->
           let rec aux item =
             Js.Opt.case (next item)
               (fun () ->
                  Js.Opt.iter (default ()) (fun item -> set item))
               (fun item ->
                  let item = (Js.Unsafe.coerce item :> Dom_html.element Js.t) in
                  if contains item Style.traversable_elt_cls
                  then set item
                  else aux item)
           in aux (Content.to_dom_elt active))
    in

    elt'##_getContainer <-
    meth (fun this () ->
      elt
    );

    elt'##_prev <-
    meth (fun this () ->
      move this
        ~default:(fun () -> elt'##lastChild)
        ~next:(fun elt -> elt##previousSibling)
    );

    elt'##_next <-
    meth (fun this () ->
      move this
        ~default:(fun () -> elt'##firstChild)
        ~next:(fun elt -> elt##nextSibling)
    );

    let (!$) q = elt'##querySelector(Js.string q) in

    elt'##_resetActive <-
    meth (fun this () ->
      Js.Opt.iter (this##getActive())
        (fun item ->
           (Content.to_dom_elt item)##classList##remove(Js.string Style.selected_cls));
    );

    elt'##_getActive <-
    meth (fun this () ->
      Js.Opt.case (!$ (Printf.sprintf "li.%s.%s" Style.traversable_elt_cls Style.selected_cls))
        (fun () -> Js.null)
        (fun item -> Js.some (Content.of_dom_elt item))
    );

    elt'##_setActive <-
    meth (fun this item ->
      (Js.Unsafe.coerce this)##_setActiveBy(`Explicit, item)
    );

    elt'##_setActiveBy <-
    meth (fun this by item ->
      Js.Opt.case ((Content.to_dom_elt item)##parentNode)
        (* if there is no parent, so item is not a child of
         * the traversable element *)
        (fun () -> ())
        (fun parent ->
           if not (parent = ((D.to_dom_elt elt) :> Dom.node Js.t))
           then ()
           else (
             Js.Opt.iter (this##getActive())
               (fun item ->
                  (Content.to_dom_elt item)##classList##remove(Js.string Style.selected_cls));
             (Content.to_dom_elt item)##classList##add(Js.string Style.selected_cls);
             if focus then
               Js.Opt.iter ((Content.to_dom_elt item)##firstChild)
                 (fun item -> (Js.Unsafe.coerce item)##focus());
             let detail = Js.Unsafe.obj [||] in
             detail##_by <- meth (fun this () -> by);
             Ojw_event.dispatchEvent this
               (Ojw_event.customEvent ~detail Event.S.active);
             ()))
    );

    elt'##_isTraversable <-
    meth (fun this () ->
      is_traversable this
    );

    Lwt.async (fun () ->
      Lwt_js_events.keydowns Dom_html.document
        (fun e _ ->
           if elt'##isTraversable() then begin
             let prevent = ref false in
             (match e##keyCode with
              | 38 -> (* up *)
                  elt'##prev(); prevent := true
              | 40 -> (* down *)
                  elt'##next(); prevent := true
              | _ -> ());
             lwt () =
               if !prevent
               then lwt _ = on_keydown e in Lwt.return ()
               else lwt p = on_keydown e in Lwt.return (prevent := p);
             in
             if !prevent then Dom.preventDefault e;
             Lwt.return ()
           end else Lwt.return ()
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
                                elt'##setActiveBy(`Click, (Content.of_dom_elt elt));
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
