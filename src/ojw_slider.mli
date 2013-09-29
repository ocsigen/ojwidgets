(* Copyright Université Paris Diderot. *)

(** Binding of the jQuery_ui slider for ocaml.

    To use it, you must include jquery-ui.js and jquery-1.9.1.js

    @author Christophe Lecointe
    @see < http://api.jqueryui.com/slider/ > JQueryUI slider.
*)

(** Add a slider to the given element.
    @param vertical Whether the slider is vertical or not. If it is not present, the slider will be horizontal.
    @param slide A function called during each slide.
*)
val add_slider : ?vertical:bool -> ?slide:(unit->unit) -> Dom_html.element Js.t -> unit

(** Return the value of the slider. *)
val get_value : Dom_html.element Js.t -> int

(** Replace the callback function done on slides. *)
(* TODOC Replace or add ? it add on the scrollbar module, better be consistant on this. *)
val on_slide : Dom_html.element Js.t -> (unit -> unit) -> 'a Lwt.t
