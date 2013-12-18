
module type T = sig

  module D : Ojw_dom_sigs.T
  module Dropdown : Ojw_dropdown_sigs.T
  module Tr : Ojw_traversable_sigs.T

  class type completion = object
    inherit Dropdown.dropdown

    method value : Js.js_string Js.t Js.prop

    method clear : unit Js.meth
    method confirm : unit Lwt.t Js.meth
    method refresh : unit Lwt.t Js.meth
  end

  val completion__ :
     refresh : (int -> string -> Dropdown.Traversable.Content.element Dropdown.Traversable.Content.elt list Lwt.t)
  -> ?limit : int
  -> ?accents : bool
  -> ?from_start : bool
  -> ?force_refresh : bool
  -> ?sensitive : bool
  -> ?adaptive : bool
  -> ?auto_match : bool
  -> ?clear_input_on_confirm : bool
  -> ?move_with_tab : bool
  -> ?on_confirm : (string -> unit Lwt.t)
  -> D.element D.elt
  -> Dropdown.Traversable.D.element Dropdown.Traversable.D.elt
  -> (Dropdown.D.element Dropdown.D.elt *
      Dropdown.Traversable.D.element Dropdown.Traversable.D.elt)
end
