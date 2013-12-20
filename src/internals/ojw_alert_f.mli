

module Make (D : Ojw_dom_sigs.T)(Content : Ojw_dom_sigs.T) :
  Ojw_alert_sigs.T
  with module D = D
  with module Content = Content
