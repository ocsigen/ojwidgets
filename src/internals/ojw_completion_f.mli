
module Utils : sig
    val is_completed_by :
         ?accents : bool
      -> ?sensitive : bool
      -> ?from_start : bool
      -> pattern : Js.js_string Js.t
      -> Js.js_string Js.t
      -> bool
end

module Make
    (D : Ojw_dom_sigs.T)
    (Dropdown : Ojw_dropdown_sigs.T
     with module D = D
      and module Button.D = D)
  : Ojw_completion_sigs.T
    with module D = D
    with module Dropdown = Dropdown
