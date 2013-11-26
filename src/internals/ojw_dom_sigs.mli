
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

module type Opt = sig
  type 'a opt

  type 'a elt
  type element
  type item_element

  val to_opt : 'a Js.opt -> 'a opt
  val of_opt : 'a opt -> 'a Js.opt

  val opt_none : 'a opt
  val opt_some : 'a -> 'a opt

  val opt_iter : 'a opt -> ('a -> unit) -> unit
  val opt_case : 'a opt -> (unit -> 'b) -> ('a -> 'b) -> 'b

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt

  val to_dom_item_elt : item_element elt -> Dom_html.element Js.t
  val of_dom_item_elt : Dom_html.element Js.t -> item_element elt
end
