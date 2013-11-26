
module type T = sig

  module D : Dom_conv.T

  module Button : Button_sigs.T
  module Traversable : Traversable_sigs.T

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
