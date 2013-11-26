
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

    method alert : Alert.t Js.opt Js.prop
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
    -> D.element D.elt
    -> D.element D.elt

  val button_alert :
    ?set:Ojw_active_set.t
    -> ?pressed:bool
         (*
    -> ?before:(Alert.D.element Alert.D.elt -> unit)
    -> ?after:(Alert.D.element Alert.D.elt -> unit)
    -> ?parent:(Alert.parent Alert.D.elt)
    -> ?on_close:(unit -> unit)
          *)
    -> D.element D.elt
         (*
    -> (Alert.t -> Alert.D.element Alert.D.elt)
          *)
    -> Alert.D.element Alert.D.elt
    -> D.element D.elt

  val to_button : D.element D.elt -> button Js.t
end
