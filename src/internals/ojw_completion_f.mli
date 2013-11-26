

module Make
    (D : Ojw_dom_sigs.T)
    (Dropdown : Ojw_dropdown_sigs.T
     with module D = D
      and module Button.D = D)
  : Ojw_completion_sigs.T
    with module D = D
    with module Dropdown = Dropdown
