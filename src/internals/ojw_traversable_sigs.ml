(* This file is needed by oasis/ocamlbuild for now.
   It will not be needed with the next version of oasis.
   It must stay strictly eual to his .mli
*)

module type T = sig

  module D : Ojw_dom_sigs.T
  module Content : Ojw_dom_sigs.T

  type by = [
      | `Click
      | `Key of int
      | `Explicit
  ]

  class type traversable_detail_event = object
    method by : by Js.meth
  end

  class type traversable_event = [traversable_detail_event] Ojw_event.customEvent

  module Event : sig
    type event = traversable_event Js.t Dom.Event.typ

    val actives : event
  end

  val active : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> traversable_event Js.t Lwt.t

  val actives :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (traversable_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  class type traversable = object
    inherit Ojw_base_widget.widget

    method getContainer : D.element D.elt Js.meth

    method next : unit Js.meth
    method prev : unit Js.meth
    method resetActive : unit Js.meth
    method setActive : Content.element Content.elt -> unit Js.meth
    method getActive : Content.element Content.elt Js.opt Js.meth
    method isTraversable : bool Js.meth
  end

  module Style : sig
    val traversable_cls : string
    val traversable_elt_cls : string
    val selected_cls : string
  end

  val traversable :
     ?enable_link : bool
  -> ?focus : bool
  -> ?is_traversable : (#traversable Js.t -> bool)
  -> ?on_keydown : (Dom_html.keyboardEvent Js.t -> bool Lwt.t)
  -> D.element D.elt
  -> D.element D.elt

  val to_traversable : D.element D.elt -> traversable Js.t
end
