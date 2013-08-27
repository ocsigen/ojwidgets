(* position / coordinated *)

type position_type = Client | Screen | Page
type touch_type = All_touches | Target_touches | Changed_touches

(** p_type is at Client by default *)
val get_mouse_ev_coord :
  ?p_type:position_type ->
  Dom_html.mouseEvent Js.t ->
  int * int

(** p_type is at Client by default *)
val get_touch_coord :
  ?p_type:position_type ->
  Dom_html.touch Js.t ->
  int * int

(** Based on get_touch_coord

    Int arg is the id of touch

    t_type is at All_touches by default *)
val get_touch_ev_coord :
  ?t_type:touch_type ->
  int ->
  ?p_type:position_type ->
  Dom_html.touchEvent Js.t -> int * int

(** Based on get_mouse_ev_coord

    Element arg is the target *)
val get_local_mouse_ev_coord :
  #Dom_html.element Js.t ->
  ?p_type:position_type ->
  Dom_html.mouseEvent Js.t ->
  int * int

(** Based on get_touch_ev_coord

    Second arg is the target
    Third is the index of touch *)
val get_local_touch_ev_coord :
  #Dom_html.element Js.t ->
  ?t_type:touch_type ->
  int ->
  ?p_type:position_type ->
  Dom_html.touchEvent Js.t ->
  int * int

(** take two coordonne and return true if they are egal *)
val cmp_coord : (int * int) -> (int * int) -> bool

(*** Enable / Disable ***)

(** Disable Dom_html.Event with stopping propagation during capture phase **)
val disable_event :  'a #Dom.event Js.t Dom_html.Event.typ ->
  #Dom_html.eventTarget Js.t ->
  Dom_html.event_listener_id

(** Enable Dom_html.Event with id gived by disable_event **)
val enable_event : Dom_html.event_listener_id -> unit

val enable_events : Dom_html.event_listener_id list -> unit

val disable_drag_and_drop : #Dom_html.eventTarget Js.t ->
  Dom_html.event_listener_id list
