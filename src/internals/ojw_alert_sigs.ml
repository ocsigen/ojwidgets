(* This file is needed by oasis/ocamlbuild for now.
   It will not be needed with the next version of oasis.
   It must stay strictly eual to his .mli
*)

module type T = sig
  module D : Ojw_dom_sigs.T
  module Content : Ojw_dom_sigs.T

  class type alert_event = object
    inherit Dom_html.event
  end

  module Event : sig
    type event = alert_event Js.t Dom.Event.typ

    module S : sig
      val show : string
      val hide : string
    end

    val show : event
    val hide : event
  end

  val show : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val hide : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val outer_click : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t

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

  val outer_clicks :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  class type alert = object
    inherit Ojw_base_widget.widget

    method visible : bool Js.meth
    method show : unit Js.meth
    method hide : unit Js.meth
  end

  class type dyn_alert = object
    inherit Ojw_base_widget.widget

    method visible : bool Js.meth
    method show : unit Lwt.t Js.meth
    method hide : unit Js.meth
    method update : unit Lwt.t Js.meth
  end

  val prevent_outer_clicks : #Dom_html.element Js.t -> unit

  val alert :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?on_outer_click:(alert Js.t -> unit)
  -> ?before:(D.element D.elt -> unit)
  -> ?after:(D.element D.elt -> unit)
  -> D.element D.elt
  -> D.element D.elt

  val dyn_alert :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?on_outer_click:(dyn_alert Js.t -> unit)
  -> ?before:(D.element D.elt -> unit Lwt.t)
  -> ?after:(D.element D.elt -> unit Lwt.t)
  -> D.element D.elt
  -> (D.element D.elt -> Content.element Content.elt list Lwt.t)
  -> D.element D.elt

  val to_alert :
     D.element D.elt
  -> alert Js.t

  val to_dyn_alert :
     D.element D.elt
  -> dyn_alert Js.t

end
