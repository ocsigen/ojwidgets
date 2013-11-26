
module type T = sig

  module D : Dom_conv.Opt

  class type traversable = object
    inherit Ojw_base_widget.widget

    method getContainer : D.element D.elt Js.meth

    method next : unit Js.meth
    method prev : unit Js.meth
    method resetActive : unit Js.meth
    method setActive : D.element D.elt -> unit Js.meth
    method getActive : D.element D.elt D.opt Js.meth
    method isTraversable : bool Js.meth
  end

  val traversable :
      ?enable_link : bool
  -> ?focus : bool
  -> ?is_traversable : (#traversable Js.t -> bool)
  -> ?on_keydown : (Dom_html.keyboardEvent Js.t -> bool)
  -> D.element D.elt
  -> D.element D.elt

  val to_traversable : D.element D.elt -> traversable Js.t
end
