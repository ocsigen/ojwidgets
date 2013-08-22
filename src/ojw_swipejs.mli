(*
 * Swipe 2.0
 *
 * Arnaud Parant
 * Copyright 2013, MIT License
 *
 *)

type jq_elt
type t

class type options =
object
  method startSlide : int Js.t Js.writeonly_prop
  method auto : int Js.t Js.writeonly_prop
  method continous : int Js.t Js.writeonly_prop
  method disableScroll : bool Js.t Js.writeonly_prop
  method stopPropagation : bool Js.t Js.writeonly_prop
  method callback : (int -> 'a -> unit) Js.callback Js.writeonly_prop
  method transitionEnd : (int -> 'a -> unit) Js.callback Js.writeonly_prop
end

(** create html_content

    Return:
      - html_elt to include in your page
      - jq_elt to be able to init swipe *)
val create :
  #Dom.node Js.t ->
  Dom_html.divElement Js.t * jq_elt

val empty_options : unit -> options Js.t

(** You need to initialize your swipe content with default value
    to allow future update *)
val init : jq_elt -> ?options:(options Js.t) -> unit -> t

(** Start motion
    If you set another swipe after, the first will be stoped *)
val start : t -> unit

val next : t -> unit

val prev : t -> unit

val get_position : t -> int

val get_number_of_slides : t -> int

(** slide_to [js_swipe index duration unit]

    duration: milliseconds (300 = 300ms) *)
val slide_to : t -> int -> ?duration:int -> unit -> unit
