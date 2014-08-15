(*
   Swipe 2.0
  
   Arnaud Parant
   Copyright 2013, MIT License
  
 *)


(** Swiping library.
    @author Arnaud Parant
*)
(* TODOC More info ? *)

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
(* TODOC Some options may deserve some explainations. *)

(** Create a swipe from an dom node.
    Return the element to be included in your page and [jq_elt], to be able to init swipe *)
val create :
  #Dom.node Js.t ->
  Dom_html.divElement Js.t * jq_elt

val empty_options : unit -> options Js.t

(** You need to initialize your swipe content with default values
    to allow future update *)
val init : jq_elt -> ?options:(options Js.t) -> unit -> t
(* TODOC : why separate this from create ? jq_elt seems to be used only for this. *)

(** Start motion.
    If you set another swipe after, the first will be stoped *)
val start : t -> unit

val next : t -> unit

val prev : t -> unit

val get_position : t -> int

val get_number_of_slides : t -> int

(** Jump to a specific slide.
    @param duration in milliseconds *) (* TODOC : default for duration ? *)
val slide_to : t -> int -> ?duration:int -> unit -> unit
