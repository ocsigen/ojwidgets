

module Make
    (D : Dom_conv.T)
    (Dropdown : Dropdown_sigs.T
     with module D = D
      and module Button.D = D
      and type Traversable.D.element = D.element
      and type 'a Traversable.D.elt = 'a D.elt)
  : Completion_sigs.T
    with module D = D
    with module Dropdown = Dropdown
