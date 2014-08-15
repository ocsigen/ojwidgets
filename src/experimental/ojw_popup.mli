(** Popups are a special kind of [alerts] that are automatically showed in
    the middle of the screen. *)

include Ojw_popup_sigs.T
  with module D = Ojw_dom.T
  with module Alert = Ojw_alert
