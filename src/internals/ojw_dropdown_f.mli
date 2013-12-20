

module Make
    (D : Ojw_dom_sigs.T)
    (Button : Ojw_button_sigs.T
     with module D = D)
    (Traversable : Ojw_traversable_sigs.T)
  : Ojw_dropdown_sigs.T
    with module Traversable = Traversable
    with module Button = Button
    with module D = D
