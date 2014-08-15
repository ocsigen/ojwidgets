module type T = sig
  module D : Ojw_dom_sigs.T
  module Alert : Ojw_alert_sigs.T

  (** {2 Helpers} *)

  (** Internal background is shown when a popup is triggered. *)
  val show_background : unit -> unit

  (** Internal background id hidden when a popup is triggered. *)
  val hide_background : unit -> unit

  (** {2 Construction functions} *)

  (** Specialization of a [Ojw_alert.alert] that shows a transparent
      background if [with_background] is set to [true]. *)
  val popup :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?with_background:bool
  -> D.element D.elt
  -> D.element D.elt

  (** Specialization of a [Ojw_alert.dyn_alert] that shows a transparent
      background if [with_background] is set to [true].  *)
  val dyn_popup :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?with_background:bool
  -> D.element D.elt
  -> (Alert.D.element Alert.D.elt -> Alert.Content.element Alert.Content.elt list Lwt.t)
  -> D.element D.elt

  (** Alias to [Ojw_alert_sigs.closeable_by_click] *)
  val closeable_by_click : D.element D.elt -> D.element D.elt

  (** {2 Conversion functions} *)

  (** Tests if an element is an alert or not and returns it as a [popup]
      instance. *)
  val to_popup : D.element D.elt -> Alert.alert Js.t

  (** Tests if an element is an alert or not and returns it as a [dyn_popup]
      instance. *)
  val to_dyn_popup : D.element D.elt -> Alert.dyn_alert Js.t
end
