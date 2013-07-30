(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

(** Widgets which act like a mutable popup. You can re-set the content of it
  * by changing the footer, header or the body. There is also some options
  * to enable a black background behind it (like a modal) or also add a close
  * button to the popup.
  * *)
class popup :
     ?width:int (** The width of the popup (default: 500) *)
  -> ?close_button:bool (** Add a close button to the popup if true *)
  -> ?with_background:bool (** Add a background behind the popup if true *)
  -> ?header:Dom_html.element Js.t list (** Header of the popup *)
  -> ?footer:Dom_html.element Js.t list (** Footer of the popup *)
  -> ?body:Dom_html.element Js.t list (** Body of the popup *)
  -> ?set:(unit -> unit Lwt.t) ref (** Radio set button *)
  -> Dom_html.element Js.t (** Html element which will show
                               the popup when clicked *)
  ->
object
  inherit Ojw_button.alert

  (** Change the popup's header *)
  method set_header : Dom_html.element Js.t list -> unit
  (** Change the popup's body *)
  method set_body : Dom_html.element Js.t list -> unit
  (** Change the popup's footer *)
  method set_footer : Dom_html.element Js.t list -> unit
  (** Force the update of the popup, if the content has been changed *)
  method update : unit
  (** Return the html equivalent of the popup (to include it into the
    * dom for exemple) *)
  method to_html : Dom_html.element Js.t

  (** Change the width of the popup *)
  method set_width : int -> unit
  (** Get the width of the popup *)
  method get_width : int

  (** Close the popup *)
  method close : unit Lwt.t
  (** Show the popup *)
  method show : unit Lwt.t
end
