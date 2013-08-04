(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_alert_m
  : Button_alert_f.In with type button_t = Dom_html.element Js.t

(** Alert displays an alert box when a button is pressed.
    [get_node] returns the list of elements to be displayed and

    Redefine [get_node] for your needs.

    If you want the alert to be opened at start,
    give an element as [pressed] parameter.
    It must have at the right parent in the page (body by default).

    After getting the node,
    the object is inserted as JS field [o] of the DOM element of
    the alert box.
*)
class alert :
     ?set:(unit -> unit Lwt.t) ref
  -> ?allow_outer_click:bool
  -> ?pressed:Dom_html.divElement Js.t
  -> ?closeable_by_method:bool
  -> ?closeable_by_button:bool
  -> ?button:Dom_html.element Js.t
  -> ?parent_node:Dom_html.element Js.t
  -> ?class_:string list
  -> unit
  ->
object
  val mutable node : Dom_html.divElement Js.t option
  val mutable parent_node : Dom_html.element Js.t

  inherit Button.button

  method set_parent_node : Dom_html.element Js.t -> unit
  method get_alert_box : Dom_html.divElement Js.t option
  method get_node : Dom_html.element Js.t list Lwt.t
end
