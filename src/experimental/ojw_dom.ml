
external nothing : 'a -> 'a = "%identity"

module T :
  Ojw_dom_sigs.T
  with type 'a elt = Dom_html.element Js.t
   and type element = Dom_html.element
= struct
  type 'a elt = Dom_html.element Js.t
  type element = Dom_html.element

  let to_dom_elt = nothing
  let of_dom_elt = nothing
end

module Parent :
  Ojw_dom_sigs.Parent
  with type 'a elt = Dom_html.element Js.t
   and type element = Dom_html.element
   and type parent = Dom_html.element
= struct
  type 'a elt = Dom_html.element Js.t

  type parent = Dom_html.element
  type element = Dom_html.element

  let to_dom_elt = nothing
  let of_dom_elt = nothing
  let to_dom_parent = nothing

  let default_parent () = Dom_html.document##body
end

module Opt :
  Ojw_dom_sigs.Opt
  with type 'a elt = Dom_html.element Js.t
   and type element = Dom_html.element
   and type item_element = Dom_html.element
   and type 'a opt = 'a Js.opt
= struct
    type 'a opt = 'a Js.opt

    type 'a elt = Dom_html.element Js.t
    type element = Dom_html.element
    type item_element = Dom_html.element

    let to_opt = nothing
    let of_opt = nothing

    let opt_none = Js.null
    let opt_some = Js.some

    let opt_iter = Js.Opt.iter
    let opt_case = Js.Opt.case

    let to_dom_elt = nothing
    let of_dom_elt = nothing

    let to_dom_item_elt = nothing
    let of_dom_item_elt = nothing
  end
