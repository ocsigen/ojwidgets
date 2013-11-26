
module Make
    (D : Dom_conv.T)
    (Alert : Alert_sigs.T
     with type D.element = D.element
      and type 'a D.elt = 'a D.elt)
  : Button_sigs.T
    with module D = D
     and module Alert = Alert
