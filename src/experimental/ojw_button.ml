
let nothing r = r
module M = Ojw_internals.Button_f.Make
    (struct
      type 'a elt = Dom_html.element Js.t
      type element = Dom_html.element

      let to_dom_elt = nothing
      let of_dom_elt = nothing
    end)
    (Ojw_alert)

include M
