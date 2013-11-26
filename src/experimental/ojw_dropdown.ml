
let nothing r = r
module M =
  Ojw_internals.Dropdown_f.Make
    (struct
      type element = Dom_html.element
      type 'a elt = Dom_html.element Js.t

      let to_dom_elt = nothing
      let of_dom_elt = nothing
    end)
    (Ojw_button)
    (Ojw_traversable)

include M
