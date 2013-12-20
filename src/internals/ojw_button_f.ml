open Dom_html
open Dom


module Make
    (D : Ojw_dom_sigs.T)
    (Alert : Ojw_alert_sigs.T
     with type D.element = D.element
      and type 'a D.elt = 'a D.elt)
= struct
  module D = D
  module Alert = Alert

  class type button = object
    inherit Ojw_active_set.item
    inherit Ojw_base_widget.widget

    method pressed : bool Js.t Js.readonly_prop

    method prevent : bool Js.t -> unit Js.meth
    method press : unit Js.meth
    method unpress : unit Js.meth
    method toggle : unit Js.meth
  end

  class type button' = object
    inherit button

    inherit Ojw_active_set.item'
    inherit Ojw_base_widget.widget'

    method _prevented : bool Js.t Js.prop
    method _prevent : (#button Js.t, bool Js.t -> unit) Js.meth_callback Js.prop

    method _press : (#button Js.t, unit -> unit) Js.meth_callback Js.prop
    method _unpress : (#button Js.t, unit -> unit) Js.meth_callback Js.prop
    method _toggle : (#button Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  class type button_alert = object
    inherit button
  end

  class type button_dyn_alert = object
    inherit button_alert

    method update : unit Lwt.t Js.meth
  end

  class type button_dyn_alert' = object
    inherit button_dyn_alert

    method _update : (#button_dyn_alert Js.t, unit -> unit Lwt.t) Js.meth_callback Js.prop
  end

  class type button_event = object
    inherit Dom_html.event
  end

  module Event = struct
    type event = button_event Js.t Dom.Event.typ

    module S = struct
      let press = "press"
      let unpress = "unpress"

      let pre_press = "pre_press"
      let pre_unpress = "pre_unpress"

      let post_press = "post_press"
      let post_unpress = "post_unpress"
    end

    let press : event = Dom.Event.make S.press
    let unpress : event = Dom.Event.make S.unpress

    let pre_press : event = Dom.Event.make S.pre_press
    let pre_unpress : event = Dom.Event.make S.pre_unpress

    let post_press : event = Dom.Event.make S.post_press
    let post_unpress : event = Dom.Event.make S.post_unpress
  end

  let press ?use_capture target =
    Lwt_js_events.make_event Event.press ?use_capture target
  let unpress ?use_capture target =
    Lwt_js_events.make_event Event.unpress ?use_capture target

  let pre_press ?use_capture target =
    Lwt_js_events.make_event Event.pre_press ?use_capture target
  let pre_unpress ?use_capture target =
    Lwt_js_events.make_event Event.pre_unpress ?use_capture target

  let post_press ?use_capture target =
    Lwt_js_events.make_event Event.post_press ?use_capture target
  let post_unpress ?use_capture target =
    Lwt_js_events.make_event Event.post_unpress ?use_capture target


  let presses ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop press ?cancel_handler ?use_capture (D.to_dom_elt t)
  let unpresses ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop unpress ?cancel_handler ?use_capture (D.to_dom_elt t)

  let pre_presses ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop pre_press ?cancel_handler ?use_capture (D.to_dom_elt t)
  let pre_unpresses ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop pre_unpress ?cancel_handler ?use_capture (D.to_dom_elt t)

  let post_presses ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop post_press ?cancel_handler ?use_capture (D.to_dom_elt t)
  let post_unpresses ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop post_unpress ?cancel_handler ?use_capture (D.to_dom_elt t)

  let default_predicate () =
    Lwt.return true

  let button ?set ?(pressed = false) ?(predicate = default_predicate) elt =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) : button' Js.t) in
    let meth = Js.wrap_meth_callback in

    let wbutton b = (Js.Unsafe.coerce b : button' Js.t) in

    let internal_press b =
      let this = (elt' :> button Js.t) in
      (Js.Unsafe.coerce this)##pressed <- Js.bool b;
      if Js.to_bool this##pressed
      then this##classList##add(Js.string "pressed")
      else this##classList##remove(Js.string "pressed")
    in

    ignore (Ojw_base_widget.ctor elt' "button");
    ignore (
      Ojw_active_set.ctor
        ~enable:(fun this () ->
            let wthis = wbutton this in
            Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.pre_press);
            if not (wthis##_prevented = Js._true) then begin
              Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.press);
              internal_press true;
              Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.post_press);
            end;
            wthis##_prevented <- Js._false
          )
        ~disable:(fun this () ->
            let wthis = wbutton this in
            Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.pre_unpress);
            if not ((wbutton this)##_prevented = Js._true) then begin
              Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.unpress);
              internal_press false;
              Ojw_event.dispatchEvent this (Ojw_event.customEvent Event.S.post_unpress);
            end;
            wthis##_prevented <- Js._false
          )
        elt'
    );

    elt'##_press <-
    meth (fun this () ->
      match set with
      | None -> this##enable()
      | Some set ->
          Ojw_active_set.enable ~set (this :> Ojw_active_set.item Js.t)
    );

    elt'##_unpress <-
    meth (fun this () ->
      match set with
      | None -> this##disable()
      | Some set ->
          Ojw_active_set.disable ~set (this :> Ojw_active_set.item Js.t)
    );

    elt'##_toggle <-
    meth (fun this () ->
      if Js.to_bool this##pressed
      then this##unpress()
      else this##press()
    );

    elt'##_prevented <- Js._false;

    elt'##_prevent <-
    meth (fun this prevent ->
      (wbutton this)##_prevented <- prevent;
    );

    (Js.Unsafe.coerce elt')##pressed <- false;
    if pressed then
      elt'##press()
    else
      elt'##unpress();

    Lwt.async (fun () ->
      Lwt_js_events.clicks (D.to_dom_elt elt)
        (fun e _ ->
           lwt ret = predicate () in
           if ret then
             elt'##toggle();
           Lwt.return ()));
    elt

  let button_alert
      ?set ?pressed
      ?predicate
      ?allow_outer_clicks
      ?before
      ?after
      elt elt_alert =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) : button_alert Js.t) in
    let elt_alert' = Alert.to_alert elt_alert in

    let before, after =
      match before, after with
      | None, None -> (fun _ -> ()), (fun _ -> ())
      | Some before, None -> before elt, (fun _ -> ())
      | None, Some after  -> (fun _ -> ()), after elt
      | Some before, Some after  -> before elt, after elt
    in

    let on_outer_click _ =
      elt'##unpress()
    in

    ignore (Alert.alert ?allow_outer_clicks ~on_outer_click ~before ~after elt_alert);
    Alert.prevent_outer_clicks elt;

    Lwt.async (fun () ->
      presses elt
        (fun _ _ ->
           Ojw_log.log "show";
           elt_alert'##show();
           Lwt.return ()));

    Lwt.async (fun () ->
      unpresses elt
        (fun _ _ ->
           elt_alert'##hide();
           Lwt.return ()));

    Lwt.async (fun () ->
      Alert.outer_clicks elt
        (fun _ _ ->
           elt'##unpress();
           Lwt.return ()));

    (* We want to listen events before unpress or press the button *)
    ignore (button ?set ?pressed ?predicate elt);

    (elt, elt_alert)

    let button_dyn_alert
      ?set ?pressed
      ?predicate
      ?allow_outer_clicks
      ?before
      ?after
      elt elt_alert f =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) : button_dyn_alert' Js.t) in
    let elt_alert' = Alert.to_dyn_alert elt_alert in
    let meth = Js.wrap_meth_callback in

    let before, after =
      match before, after with
      | None, None -> (fun _ -> Lwt.return ()), (fun _ -> Lwt.return ())
      | Some before, None -> before elt, (fun _ -> Lwt.return ())
      | None, Some after  -> (fun _ -> Lwt.return ()), after elt
      | Some before, Some after  -> before elt, after elt
    in

    let on_outer_click _ =
      elt'##unpress()
    in

    ignore (Alert.dyn_alert ?allow_outer_clicks ~on_outer_click ~before ~after elt_alert (f elt));
    Alert.prevent_outer_clicks elt;

    elt'##_update <-
    meth (fun this () ->
      elt_alert'##update();
    );

    Lwt.async (fun () ->
      presses elt
        (fun _ _ ->
           lwt () = elt_alert'##show() in
           Lwt.return ()));

    Lwt.async (fun () ->
      unpresses elt
        (fun _ _ ->
           elt_alert'##hide();
           Lwt.return ()));

    (* We want to listen events before unpress or press the button *)
    ignore (button ?set ?pressed ?predicate elt);

    (elt, elt_alert)

  let closeable_by_click = Alert.closeable_by_click

  let to_button elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> button Js.t)
  let to_button_alert elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> button_alert Js.t)
  let to_button_dyn_alert elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> button_dyn_alert Js.t)
end
