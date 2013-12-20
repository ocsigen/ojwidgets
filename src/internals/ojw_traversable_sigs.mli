
module type T = sig
  (** A traversable element can iterate through their children. *)

  module D : Ojw_dom_sigs.T
  module Content : Ojw_dom_sigs.T

  (**  {2 Specific events for alerts} *)

  (** A type which defines which interaction have been used to trigger
    * action on the [traversable] element. *)
  type by = [
      | `Click
      | `Key of int
      | `Explicit
  ]

  (** The [detail] of events of [traversable] element. The method [by]
    * indicate how the active element has been set.
    *
    * [`Explicit] mean that the function [setActive] from [traversable]
    * class has been called to set active an element.
    *
    * [`Key] holds the keycode of the last key which set to active an
    * element (up/down arrows generally).
    *
    * [`Click] means that the active element has been set using mouse.
    * *)
  class type traversable_detail_event = object
    method by : by Js.meth
  end

  (** Traversable's event type. *)
  class type traversable_event =
    [traversable_detail_event] Ojw_event.customEvent

  module Event : sig
    type event = traversable_event Js.t Dom.Event.typ

    val actives : event
  end

  val active : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> traversable_event Js.t Lwt.t

  (** This event is triggered when an element is to active. Some informations
    * are available in the [traversable_event] (see above). *)
  val actives :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (traversable_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  (** {2 Types for traversable} *)

  (** A [traversable] element can use keys to navigate through their
    * children (only one level of children).
    *
    * The element {b MUST BE} a {b ul} with {b li} children.
    *
    * {b li} elements are used as container for child and used as item
    * for the [traversable] element. They must respect some requirements.
    * They {b MUST HAVE} the css class {b "ojw_traversable_elt"}.
    *
    * Traversable is used to compose other widgets (as [Ojw_dropdown]).
    * *)
  class type traversable = object
    inherit Ojw_base_widget.widget

    (** Get the original version of the container used as [traversable]
      * element (without conversion). *)
    method getContainer : D.element D.elt Js.meth

    (** Explicitly set active the next element of the [traversable]
      * element. *)
    method next : unit Js.meth

    (** Explicitly set active the previous element of the [traversable]
      * element. *)
    method prev : unit Js.meth

    (** Make inactive the current active element. *)
    method resetActive : unit Js.meth

    (** Explicitly set to active state a [traversable]'s child. *)
    method setActive : Content.element Content.elt -> unit Js.meth

    (** Get the current active element. If there is no active element,
      * returns [Js.null]. *)
    method getActive : Content.element Content.elt Js.opt Js.meth

    (** Returns true if the [traversable] element can listen keys and
      * interpret them. Uses the [is_traversable] function on the construction
      * of the widget (see below). *)
    method isTraversable : bool Js.meth
  end

  module Style : sig
    val traversable_cls : string
    val traversable_elt_cls : string
    val selected_cls : string
  end

  (** {2 Construction functions} *)

  (** Provides the behaviour of listening keys when the element is traversable.
    *
    * Keys up and down arrows are used for navigating through children. You can
    * also click an a child to set it to active.
    *
    * When an element is active, the css class {b "selected"} is added to the
    * {b li} element.
    *
    * [enable_link] allows you to keep the default behaviour for the children
    * which are links. If it is set to [false], the link won't be interpreted.
    *
    * [focus] set the document's focus to the current active element. Beware,
    * no checks are done when giving the focus, if you use element without
    * focus interactions, you will probably run into a javascript error.
    *
    * [is_traversable] indicates whether or not the [traversable] element can
    * listen to keys events. If [false] is returned, keys events won't be
    * interpreted. This function is called each time an keydown event occurs.
    *
    * [on_keydown] is a helper function which is called each time a keydown
    * event is triggered. The return value indicates if the event must be
    * prevented or not ([Dom.preventDefault] and [Dom_html.stopPropagation]).
    * Use this function instead of adding an event listener for keydowns on
    * the [traversable] element.
    *
    * *)
  val traversable :
     ?enable_link : bool
  -> ?focus : bool
  -> ?is_traversable : (#traversable Js.t -> bool)
  -> ?on_keydown : (Dom_html.keyboardEvent Js.t -> bool Lwt.t)
  -> D.element D.elt
  -> D.element D.elt

  (** {2 Conversion functions} *)

  (** Check if the given element is an instance of a [traversable] widget. *)
  val to_traversable : D.element D.elt -> traversable Js.t
end
