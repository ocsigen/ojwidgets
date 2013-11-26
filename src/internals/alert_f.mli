

module Make (D : Dom_conv.Parent) :
  Alert_sigs.T
  with module D = D
