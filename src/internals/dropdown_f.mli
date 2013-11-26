

module Make
    (D : Dom_conv.T)
    (Button : Button_sigs.T
     with module D = D)
    (Traversable : Traversable_sigs.T
     with type D.element = D.element
      and type 'a D.elt = 'a D.elt)
  : Dropdown_sigs.T
    with module Traversable = Traversable
    with module Button = Button
    with module D = D
