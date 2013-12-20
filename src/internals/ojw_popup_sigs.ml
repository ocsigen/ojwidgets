module type T = sig

  module D : Ojw_dom_sigs.T
  module Alert : Ojw_alert_sigs.T

  val show_background : unit -> unit
  val hide_background : unit -> unit

  val popup :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?with_background:bool
  -> D.element D.elt
  -> D.element D.elt

  val closeable_by_click : D.element D.elt -> D.element D.elt

  val to_popup : D.element D.elt -> Alert.alert Js.t
end
