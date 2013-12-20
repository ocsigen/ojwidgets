
module type T = sig
  type 'a elt
  type element

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt
end

module type Parent = sig
  type 'a elt

  type parent
  type element

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt

  val to_dom_parent : parent elt -> Dom_html.element Js.t

  val default_parent : unit -> parent elt

end
