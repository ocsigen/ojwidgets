(* Copyright Université Paris Diderot*)

(**
   @author Christophe Lecointe
   Scrollbar module. Used to add customizable scrollbars to your pages.
   Binding of the
   @see < http://manos.malihu.gr/jquery-custom-content-scroller/ > JS scrollbar
*)

    (** Type used mainly to describe where the dragger should scroll to.
        `Bottom and `Top are for vertical scrollbar, `Left and `Right for
        horizontal. *)
type scroll_t =
  | Bottom
  | First
  | Int of int
  | Last
  | Left
  | Right
  | Top

(** This function add a customScrollbar to the element elt. There are
      several optionnal arguments (to have the full details, see the doc
      of the js lib used :
      http://manos.malihu.gr/jquery-custom-content-scroller/)

      - height determines the height of the scrollbar. If none, the
      scrollbar will have the size of the element.

      - scroll determines the starting position of the dragger. The dragger
    will actually be positionned

      - Inertia : scrolling inertia in milliseconds. Really low
      values (<10) are forced to 10, because it breaks the scrollbar when
      under 10. Low values are irrelevant anyway, since the user can't
      even see it. To disable the inertia, put 0.

      - mouseWheelPixel : Mouse wheel scrolling amount in pixel. If
      undefined , the value "auto" is used. *)
val add_scrollbar : ?height:(Dom_html.element Js.t -> int) ->
  ?scroll:scroll_t ->
  ?inertia:int ->
  ?mouse_wheel_pixels:int ->
  ?on_scroll_callback:(unit -> unit) ->
  ?on_scroll_start_callback:(unit -> unit) ->
  ?on_total_scroll_callback:(unit -> unit) ->
  ?on_total_scroll_back_callback:(unit -> unit) ->
  ?while_scrolling_callback:(unit -> unit) ->
  ?on_total_scroll_offset:int ->
  ?on_total_scroll_back_offset:int ->
  Dom_html.element Js.t -> unit Lwt.t

(** Returns the position of the dragger. The position is updated only
    when the dragger has finished its movement. Thus if you call it while the
    dragger is moving, the position returned will be the position of the
    dragger before the scroll *)
val get_dragger_pos : #Dom_html.element Js.t -> int

(** Returns the position of the dragger in the bar in percent. As
    get_dragger_pos, the position is only updated when the dragger has
    finished its movement. *)
val get_dragger_pct : #Dom_html.element Js.t -> int

(** lwt_scroll_to , as its name suggests, scroll the scrollbar bound
    to elt to a point defined by scroll ([ `Bottom | `First | `Int of int |
    |`Last | `Left | `Right | `Top ]). It returns a thread which end when
    the scrolling is done (immadiately if inertia is desactivated).*)
val lwt_scroll_to : ?scroll:scroll_t  ->
  #Dom_html.element Js.t -> unit Lwt.t




(** Update the scrollbar. You should call this function each time the content of the element the scrollbar is attached to is changed. *)
val update : ?height:(Dom_html.element Js.t -> int) ->
  ?scroll:scroll_t -> Dom_html.element Js.t -> unit Lwt.t

(** Adds a function to the list of function to do when a scroll
 is required, and before it is actually done. *)
val scroll_starts : (unit -> unit) -> #Dom_html.element Js.t -> 'a Lwt.t

(** Adds a function to the list of function to do after
    a scroll. *)
val scrolls : (unit -> unit) -> #Dom_html.element Js.t -> 'a Lwt.t
