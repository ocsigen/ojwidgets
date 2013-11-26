
module type T = sig

  module D : Ojw_dom_sigs.T
  module Dropdown : Ojw_dropdown_sigs.T

  class type completion = object
    inherit Dropdown.dropdown

    method value : Js.js_string Js.t Js.prop

    method clear : unit Js.meth
    method refresh : unit Js.meth
  end

  class type completion' = object
    inherit completion

    method _clear : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
    method _refresh : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  val completion :
     refresh : (string -> Dropdown.Traversable.D.item_element Dropdown.Traversable.D.elt list)
  -> D.element D.elt
  -> Dropdown.Traversable.D.element Dropdown.Traversable.D.elt
  -> (Dropdown.D.element Dropdown.D.elt *
      Dropdown.Traversable.D.element Dropdown.Traversable.D.elt)
end
