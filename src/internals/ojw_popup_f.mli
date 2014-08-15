
module Make
    (D : Ojw_dom_sigs.T)
    (Alert : Ojw_alert_sigs.T
     with type D.element = D.element
      and type 'a D.elt = 'a D.elt)
  : Ojw_popup_sigs.T
    with module D = D
     and module Alert = Alert
