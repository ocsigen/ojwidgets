(* Copyright Université Paris Diderot. *)

(** Binding of the jQuery_ui slider for ocaml. http://api.jqueryui.com/slider/
@author Christophe Lecointe *)

(** Add a slider to the given element.
@param vertical : Whether the slider is vertical or not. If it is not present, the slider will be horizontal.
@param slide : A function called during each slide.
*)
val add_slider : ?vertical:bool -> ?slide:(unit->unit) -> #Dom_html.element Js.t -> unit

(** Return the value of the slider. *)
val get_value : #Dom_html.element Js.t -> int

(** Replace the callback function done on slides. *)
val on_slide : _ Eliom_content.Html5.elt -> (unit -> unit) -> 'a Lwt.t
}}
