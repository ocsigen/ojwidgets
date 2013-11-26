open Dom
open Dom_html

module Make(D : Dom_conv.Parent) = struct
  exception Close_during_initialization

  module D = D

  type t_ = {
    parent : Dom_html.element Js.t;
    mutable container : Dom_html.element Js.t option;
  }

  type t = t_ option ref

  class type alert_event = object
    inherit Dom_html.event
  end

  module Event = struct
    type event = alert_event Js.t Dom.Event.typ

    module S = struct
      let show = "show"
      let hide = "hide"
      let close = "close"
    end

    let show : event = Dom.Event.make S.show
    let hide : event = Dom.Event.make S.hide
    let close : event = Dom.Event.make S.close
  end

  let show ?use_capture target =
    Lwt_js_events.make_event Event.show ?use_capture target
  let hide ?use_capture target =
    Lwt_js_events.make_event Event.hide ?use_capture target
  let close ?use_capture target =
    Lwt_js_events.make_event Event.close ?use_capture target


  let shows ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop show ?cancel_handler ?use_capture (D.to_dom_elt t)
  let hides ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop hide ?cancel_handler ?use_capture (D.to_dom_elt t)
  let closes ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop close ?cancel_handler ?use_capture (D.to_dom_elt t)

  class type alert = object
    inherit Ojw_base_widget.widget

    method visible : unit -> bool Js.t Js.meth
    method show : unit Js.meth
    method hide : unit Js.meth
  end

  class type alert' = object
    inherit alert

    method _visible : (#alert Js.t, unit -> bool Js.t) Js.meth_callback Js.prop
    method _show : (#alert Js.t, unit -> unit) Js.meth_callback Js.prop
    method _hide : (#alert Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  class type dyn_alert = object
    inherit alert

    method update : unit Js.meth
  end

  let alert ?(show = false) elt =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) :> alert' Js.t) in
    let meth = Js.wrap_meth_callback in

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
      this##style##display <- display
    );

    elt'##_hide <-
    meth (fun this () ->
      this##style##display <- Js.string "none"
    );

    elt'##_visible <-
    meth (fun this () ->
      Js.bool (not (this##style##display = (Js.string "none")))
    );

    if not show then
      elt'##hide();

    elt

      (*

  let dyn_alert ?parent ?before ?after f =
    let p = match parent with
      | None -> (fun () -> D.to_dom_parent (D.default_parent ()))
      | Some p -> (fun () -> D.to_dom_parent p)
    in
    let alrt = ref None in
    let p = p () in
    let c = f alrt in
    let c' = D.to_dom_elt c in
    alrt := Some {
      parent = p;
      container = Some c';
    };
    (match before with
       | None -> ()
       | Some f -> Ojw_tools.as_dom_elt c' (fun c' -> f c));
    appendChild p c';
    (match after with
       | None -> ()
       | Some f -> f c);
    alrt

       *)

  let to_alert elt = (Js.Unsafe.coerce (D.to_dom_elt elt) :> alert Js.t)
end
