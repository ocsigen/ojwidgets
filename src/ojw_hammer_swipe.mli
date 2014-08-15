(* Hammer.JS - v1.0.6dev - 2013-07-31
   http://eightmedia.github.com/hammer.js
  
   Binding by Arnaud Parant
   Copyright (c) 2013 Jorik Tangelder <j.tangelder@gmail.com>;
   Licensed under the MIT license
 *)

(* TODOC : See ojw_swipejs.mli and do the same here. *)

type t

(** create swipe and fill with panes_list
    Swipe html element is derectly add into body
    Because it need to be in top level of body *)
val create:
  Dom_html.element Js.t list ->
  t

val init: t -> unit

val get_current_pane: t -> int

(** [show_pane t index] *)
val show_pane: t -> int -> unit

val next: t -> unit

val prev: t -> unit
