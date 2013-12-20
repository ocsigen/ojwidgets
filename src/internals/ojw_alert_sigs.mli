
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

  (**  {2 Specific events for alerts} *)

  val show : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val hide : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val outer_click : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t

  (** This events is triggered when the method [show] is called. *)
  val shows :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  (** This events is triggered when the method [hide] is called. *)
  val hides :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  (** This events is triggered when a click occurs outside of an alert box
    * or outside of an element immune to out clicks. Only [alerts] which are
    * [visible] received the event. *)
  val outer_clicks :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> D.element D.elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  (** {2 Types for alerts} *)

  (** [alert] provides methods to [show] or [hide] their content. The content
    * of the alert is static. *)
  class type alert = object
    (** Base widget. *)
    inherit Ojw_base_widget.widget

    (** This method returns [true] if the content of the [alert] is currently
      * shown. [false] if not. *)
    method visible : bool Js.meth
    (** Show the content of the [alert].
      *
      * If the method is called during the [alert] is already [visible], this
      * method has no effect. *)
    method show : unit Js.meth
    (** Hide the content of the [alert]. *)
    method hide : unit Js.meth
  end

  (** [dyn_alert] provides the same method as above, except for [show] which
    * must be used inside of the [Lwt] thread. The content of the alert is
    * dynamically generated using a function (see below). The content can be
    * refreshed using the method [update]. *)
  class type dyn_alert = object
    inherit Ojw_base_widget.widget

    (** This method returns [true] if the content of the [alert] is currently
      * shown. [false] if not. *)
    method visible : bool Js.meth
    (** Call the function associated to the [alert] to generate his content and
     * make visible the [alert].
     *
     * If the method is called during the [alert] is already [visible], this
     * method has no effect. *)
    method show : unit Lwt.t Js.meth
    (** Hide the content of the [alert]. If already hidden, the method has no
      * effect. *)
    method hide : unit Js.meth
    (** Refresh the content of the [alert] if it is visible. *)
    method update : unit Lwt.t Js.meth
  end

  (** {2 Helpers for alerts} *)

  (** Exception thrown if a [closeable] button do not find his parent. *)
  exception Close_button_not_in_alert

  (** Provides the behaviour of automatically [hide] an [alert] if the
    * element is clicked.
    *
    * The parent is found using bubble iteration (iterate through parents
    * node). Nodes with a class {b "ojw_alert"} or {b "ojw_dyn_alert"} are
    * considered as terminal node during this process.
    *
    * If no parent are found during the process, the exception
    * [Close_button_not_in_alert] is raised. *)
  val closeable_by_click : D.element D.elt -> D.element D.elt

  (* FIXME: use another module ? Which corresponds to any dom elements ? *)
  (** Prevent outer clicks on the given element (make it immune to them). *)
  val prevent_outer_clicks : D.element D.elt -> unit

  (** {2 Construction functions} *)

  (** Provides behaviours of the [alert] class to an element.
    *
    * The [show] parameter indicates whether or not the alert must be displayed
    * at start.
    * [allow_outer_clicks] allows or not outer clicks for the [alert].
    * [on_outer_click] function is called when a click outside of the alert
    * occurs.
    * The function [before] and [after] are respectively called before and after
    * the [alert] is shown. *)
  val alert :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?on_outer_click:(alert Js.t -> unit)
  -> ?before:(D.element D.elt -> unit)
  -> ?after:(D.element D.elt -> unit)
  -> D.element D.elt
  -> D.element D.elt


  (** Provides behaviours of the [dyn_alert] class to an element.
    *
    * The parameters are the same a [alert] function above.
    *
    * To construct a [dyn_alert] you must provides the container
    * on which the dynamic content will be added when the method
    * [show] or [update] is called.
    *
    * When the [dyn_alert] is hidden (using [hide]), the content is removed
    * from the container.
    *
    * [update] should only be called when a [dyn_alert] is [visible]. *)
  val dyn_alert :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?on_outer_click:(dyn_alert Js.t -> unit)
  -> ?before:(D.element D.elt -> unit Lwt.t)
  -> ?after:(D.element D.elt -> unit Lwt.t)
  -> D.element D.elt
  -> (D.element D.elt -> Content.element Content.elt list Lwt.t)
  -> D.element D.elt

  (** {2 Conversion functions} *)

  (** Tests if an element is an alert or not and returns it as a [alert]
    * instance. *)
  val to_alert :
     D.element D.elt
  -> alert Js.t

  (** Tests if an element is an dyn_alert or not and returns it as a [dyn_alert]
    * instance. *)
  val to_dyn_alert :
     D.element D.elt
  -> dyn_alert Js.t

end
