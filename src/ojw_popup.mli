(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

(** Widget which act like a mutable popup.
    @author : Charly Chevalier
*)

(** Class of a generic popup.

    [ new popup ~width ~close_button ~with_background ~header ~body ~footer ~set button ]
    will instantiate a new popup.

    - [width] is the width of the popup, 500px by default.
    - [close_button] add a close button to the popup if true.
    - [with_background] add a modal-like black background behind the popup if true.
    - [header] [footer] and [body] set the initial content of the popup.
    - [set] can contain radio set buttons.
    - [button] is the html element which will show the popup on click.

    The content of the popup can be changed with [set_header], [set_body] and [set_footer].
*)
(* TODOC : Be more precise : what does set do exactly ? Is #update necessary when the content is changed ? *)
class popup :
     ?width:int
  -> ?close_button:bool
  -> ?with_background:bool
  -> ?header:Dom_html.element Js.t list
  -> ?footer:Dom_html.element Js.t list
  -> ?body:Dom_html.element Js.t list
  -> ?set:(unit -> unit Lwt.t) ref
  -> Dom_html.element Js.t
  ->
object
  inherit Ojw_button.alert

  (** Change the popup's header. *)
  method set_header : Dom_html.element Js.t list -> unit

  (** Change the popup's body. *)
  method set_body : Dom_html.element Js.t list -> unit

  (** Change the popup's footer. *)
  method set_footer : Dom_html.element Js.t list -> unit

  (** Force the update of the popup, if the content has been changed. *)
  method update : unit

  (** Change the width of the popup. *)
  method set_width : int -> unit

  (** Get the width of the popup. *)
  method get_width : int

  (** Close the popup. *)
  method close : unit Lwt.t

  (** Show the popup. *)
  method show : unit Lwt.t
end
