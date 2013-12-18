open Dom
open Dom_html

module Make
    (D : Ojw_dom_sigs.T)
    (Content : Ojw_dom_sigs.T)
= struct
  module D = D
  module Content = Content

  class type alert_event = object
    inherit Dom_html.event
  end

  module Event = struct
    type event = alert_event Js.t Dom.Event.typ

    module S = struct
      let show = "show"
      let hide = "hide"
      let outer_click = "outer_click"
    end

    let show : event = Dom.Event.make S.show
    let hide : event = Dom.Event.make S.hide
    let outer_click : event = Dom.Event.make S.outer_click
  end

  let show ?use_capture target =
    Lwt_js_events.make_event Event.show ?use_capture target
  let hide ?use_capture target =
    Lwt_js_events.make_event Event.hide ?use_capture target
  let outer_click ?use_capture target =
    Lwt_js_events.make_event Event.outer_click ?use_capture target


  let shows ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop show ?cancel_handler ?use_capture (D.to_dom_elt t)
  let hides ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop hide ?cancel_handler ?use_capture (D.to_dom_elt t)
  let outer_clicks ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop outer_click ?cancel_handler ?use_capture (D.to_dom_elt t)

  class type alert = object
    inherit Ojw_base_widget.widget

    method visible : bool Js.meth
    method show : unit Js.meth
    method hide : unit Js.meth
  end

  class type alert' = object
    inherit alert

    method _visible : (#alert Js.t, unit -> bool) Js.meth_callback Js.prop
    method _show : (#alert Js.t, unit -> unit) Js.meth_callback Js.prop
    method _hide : (#alert Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  class type dyn_alert = object
    inherit Ojw_base_widget.widget

    method visible : bool Js.meth
    method show : unit Lwt.t Js.meth
    method hide : unit Js.meth
    method update : unit Lwt.t Js.meth
  end

  class type dyn_alert' = object
    inherit dyn_alert

    method _visible : (#dyn_alert Js.t, unit -> bool) Js.meth_callback Js.prop
    method _show : (#dyn_alert Js.t, unit -> unit Lwt.t) Js.meth_callback Js.prop
    method _hide : (#dyn_alert Js.t, unit -> unit) Js.meth_callback Js.prop
    method _update : (#dyn_alert Js.t, unit -> unit Lwt.t) Js.meth_callback Js.prop
  end

  module Style = struct
    let alert_cls = "ojw_alert"
    let dyn_alert_cls = "ojw_dyn_alert"
  end

  let created_alerts = ref ([] : alert Js.t list)

  let alert
      ?(show = false)
      ?(allow_outer_clicks = false)
      ?(before = (fun _ -> ()))
      ?(after = (fun _ -> ()))
      elt =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) :> alert' Js.t) in
    let meth = Js.wrap_meth_callback in

    elt'##classList##add(Js.string Style.alert_cls);

    if not allow_outer_clicks then begin
      created_alerts := (elt' :> alert Js.t)::!created_alerts;

      Lwt.async (fun () ->
        Lwt_js_events.clicks elt'
          (fun e _ ->
            Dom.preventDefault e;
            Dom_html.stopPropagation e;
            Lwt.return ()));
    end;

    (* FIXME:
     * Should we get the display value each time we hide the alert instead ?
     * *)
    let display = Js.string (match (Js.to_string elt'##style##display) with
        | "none" -> "block" (* should we force ? *)
        | display -> display
      );
    in

    elt'##_show <-
    meth (fun this () ->
      before elt;
      Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.show);
      this##style##display <- display;
      after elt;
    );

    elt'##_hide <-
    meth (fun this () ->
      Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.hide);
      this##style##display <- Js.string "none";
      ()
    );

    elt'##_visible <-
    meth (fun this () ->
      not (this##style##display = (Js.string "none"))
    );

    if not show then
      elt'##hide();

    elt

  (** Re-write it in a more DRY way. *)
  let dyn_alert
      ?(show = false)
      ?(allow_outer_clicks = false)
      ?(before = (fun _ -> Lwt.return ()))
      ?(after = (fun _ -> Lwt.return ()))
      elt f =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) :> dyn_alert' Js.t) in
    let meth = Js.wrap_meth_callback in

    ignore (alert ~allow_outer_clicks elt);

    elt'##classList##add(Js.string Style.dyn_alert_cls);

    (* FIXME:
     * Should we get the display value each time we hide the alert instead ?
     * *)
    let display = Js.string (match (Js.to_string elt'##style##display) with
        | "none" -> "block" (* should we force ? *)
        | display -> display
      );
    in

    let internal_show ?(event = true) ?(update_display = true) this =
      lwt () = before elt in
      lwt cnt = f elt in
      List.iter
        (fun c -> appendChild elt' (Content.to_dom_elt c))
        (cnt);
      if event then
        Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.show);
      if update_display then
        this##style##display <- display;
      lwt () = after elt in
      Lwt.return ()
    in

    let internal_clear () =
      List.iter
        (removeChild elt')
        (list_of_nodeList elt'##childNodes)
    in

    elt'##_show <-
    meth (fun this () ->
      if not this##visible() then begin
        internal_show this
      end else Lwt.return ()
    );

    elt'##_hide <-
    meth (fun this () ->
      Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.hide);
      this##style##display <- Js.string "none";
      internal_clear ()
    );

    elt'##_update <-
    meth (fun this () ->
      internal_clear ();
      internal_show ~event:false ~update_display:false this;
    );

    if show then
      Lwt.async (fun () -> elt'##show());

    elt

  let () =
    Lwt.async (fun () ->
      Lwt_js_events.clicks document
        (fun _ _ ->
          List.iter (fun elt' -> elt'##hide()) !created_alerts;
          Lwt.return ()))

  let to_alert elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> alert Js.t)
  let to_dyn_alert elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> dyn_alert Js.t)
end
