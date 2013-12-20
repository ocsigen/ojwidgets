

module Make
    ( D : Ojw_dom_sigs.T )
    ( Content : Ojw_dom_sigs.T )
  : Ojw_traversable_sigs.T
    with module D = D
     and module Content = Content
