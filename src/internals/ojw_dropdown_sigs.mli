
module type T = sig
  (** A dropdown menu is a menu which can be displayed under an element
      which will act like a [button]. *)

  module D : Ojw_dom_sigs.T
  module Button : Ojw_button_sigs.T
  module Traversable : Ojw_traversable_sigs.T

  (**  {2 Specific events for dropdowns} *)

  (** @see 'Ojw_button'. *)
  (** @see 'Ojw_traversable'. *)

  (** {2 Types for dropdown} *)

  (** A [dropdown] is a kind of [button] which triggers the menu when clicking
      on it (you can also use it with hover events, see below). It also uses
      a [traversable] element to simulate the menu (and the interactions with
      the keys).
      *)
  class type dropdown = object
    inherit Button.button

    (** Returns the [traversable] element of the [dropdown]. *)
    method traversable : Traversable.traversable Js.t Js.readonly_prop
  end

  (** {2 Construction functions} *)

  (** Provides behaviours of dropdown menu.
     
      Some of the parameters are the same as [Ojw_button] and [Ojw_traversable].
     
      The parameters [v] and [h] (respectively vertical and horizontal)
      corresponds to the orientation of the menu.
     
      You can use [hover] and [hover_timeout] if you want your [dropdown]
      triggered during hover javascript events. The [dropdown] waits
      [hover_timeout] seconds before hiding the menu.
     
      The [dropdown] is traversable only when it is opened.
     
      @see 'Ojw_button'.
      @see 'Ojw_traversable'.
      @see 'Ojw_position'.
      *)
  val dropdown :
     ?v : Ojw_position.v_orientation
  -> ?h : Ojw_position.h_orientation
  -> ?focus : bool
  -> ?hover : bool
  -> ?hover_timeout : float
  -> ?enable_link : bool
  -> ?is_traversable : (#dropdown Js.t -> bool)
  -> ?predicate : (unit -> bool Lwt.t)
  -> ?on_keydown : (Dom_html.keyboardEvent Js.t -> bool Lwt.t)
  -> Button.D.element Button.D.elt
  -> Traversable.D.element Traversable.D.elt
  -> D.element D.elt list

  (* FIXME: add conversion functions. *)
end
