(* This file is needed by oasis/ocamlbuild for now.
   It will not be needed with the next version of oasis.
   It must stay strictly eual to his .mli
*)

module type T = sig

  module D : Ojw_dom_sigs.T

  module Button : Ojw_button_sigs.T
  module Traversable : Ojw_traversable_sigs.T

  class type dropdown = object
    inherit Button.button

    method traversable : Traversable.traversable Js.t Js.readonly_prop
  end

  val dropdown :
     ?v : Ojw_position.v_orientation
  -> ?h : Ojw_position.h_orientation
  -> ?focus : bool
  -> ?hover : bool
  -> ?hover_timeout : float
  -> Button.D.element Button.D.elt
  -> Traversable.D.element Traversable.D.elt
  -> D.element D.elt list
end
