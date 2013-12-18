(* This file is needed by oasis/ocamlbuild for now.
   It will not be needed with the next version of oasis.
   It must stay strictly eual to his .mli
*)

module type T = sig

  module D : Ojw_dom_sigs.T

  module Alert : Ojw_alert_sigs.T

  class type button = object
    inherit Ojw_active_set.item
    inherit Ojw_base_widget.widget

    method pressed : bool Js.t Js.readonly_prop

    method press : unit Js.meth
    method unpress : unit Js.meth
    method toggle : unit Js.meth
    method prevent : bool Js.t -> unit Js.meth
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

  class type button_event = object
    inherit Dom_html.event
  end

  module Event : sig
    type event = button_event Js.t Dom.Event.typ

    val press : event
    val unpress : event
  end

  val pre_press : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> button_event Js.t Lwt.t
  val pre_unpress : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> button_event Js.t Lwt.t

  val press : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> button_event Js.t Lwt.t
  val unpress : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> button_event Js.t Lwt.t

  val post_press : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> button_event Js.t Lwt.t
  val post_unpress : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> button_event Js.t Lwt.t

  val pre_presses :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (button_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val pre_unpresses :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (button_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val presses :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (button_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val unpresses :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (button_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val post_presses :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (button_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val post_unpresses :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (button_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val button :
    ?set:Ojw_active_set.t
    -> ?pressed:bool
    -> ?predicate:(unit -> bool Lwt.t)
    -> D.element D.elt
    -> D.element D.elt

  val button_alert :
    ?set:Ojw_active_set.t
    -> ?pressed:bool
    -> ?predicate:(unit -> bool Lwt.t)
    -> ?allow_outer_clicks:bool
    -> ?before:(Alert.D.element Alert.D.elt -> unit)
    -> ?after:(Alert.D.element Alert.D.elt-> unit)
    -> D.element D.elt
    -> Alert.D.element Alert.D.elt
    -> (D.element D.elt * Alert.D.element Alert.D.elt)

  val button_dyn_alert :
    ?set:Ojw_active_set.t
    -> ?pressed:bool
    -> ?predicate:(unit -> bool Lwt.t)
    -> ?allow_outer_clicks:bool
    -> ?before:(Alert.D.element Alert.D.elt -> unit Lwt.t)
    -> ?after:(Alert.D.element Alert.D.elt-> unit Lwt.t)
    -> D.element D.elt
    -> Alert.D.element Alert.D.elt
    -> (Alert.D.element Alert.D.elt -> Alert.Content.element Alert.Content.elt list Lwt.t)
    -> (D.element D.elt * Alert.D.element Alert.D.elt)

  val to_button : D.element D.elt -> button Js.t
  val to_button_alert : D.element D.elt -> button_alert Js.t
  val to_button_dyn_alert : D.element D.elt -> button_dyn_alert Js.t
end
