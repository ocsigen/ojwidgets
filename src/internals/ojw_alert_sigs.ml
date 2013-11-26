(* This file is needed by oasis/ocamlbuild for now.
   It will not be needed with the next version of oasis.
   It must stay strictly eual to his .mli
*)

module type T = sig
  exception Close_during_initialization

  module D : Ojw_dom_sigs.Parent

  (** The type which reprensents an alert. *)
  type t

                                    (*

  (** [close a] closes an alert. Be aware that using this function during
    * the initialization of the alert box will raise
    * [Close_during_initialization].
    *)
  val close : t -> unit

  (** [alert ?parent ?wrap ?before ?after f] creates an alert box. The
    * content is defined using the function [f] which returns a list of
    * javascript elements.
    *
    * You can change the [parent] to which the alert box will be inserted.
    * By default, it is set to [document##body]. You can also use a specific
    * container for the alert box, using [wrap] function (default: div element).
    *
    * If you want to do some operations before inserting the alert box into the dom
    * (such as positioning your box), you can use [before] callback. There is also
    * a callback [after] which is called after insertion.
    *
    * The initialization is finished once the content of the alert box is
    * returned.
    *)
  val alert :
     ?parent:parent elt
  -> ?before:(element elt -> unit)
  -> ?after:(element elt -> unit)
  -> (t -> element elt)
  -> t


                                     *)
  class type alert_event = object
    inherit Dom_html.event
  end

  module Event : sig
    type event = alert_event Js.t Dom.Event.typ

    module S : sig
      val show : string
      val hide : string
      val close : string
    end

    val show : event
    val hide : event
    val close : event
  end

  val show : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val hide : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val close : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t

  val shows :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val hides :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val closes :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  class type alert = object
    inherit Ojw_base_widget.widget

    method visible : unit -> bool Js.t Js.meth
    method show : unit Js.meth
    method hide : unit Js.meth
  end

  val alert :
     ?show:bool
  -> D.element D.elt
  -> D.element D.elt

  val to_alert :
     D.element D.elt
  -> alert Js.t

end
