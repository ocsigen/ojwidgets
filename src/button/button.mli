(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_m
  : Button_f.In with type button_t = Dom_html.element Js.t

val new_radio_set : unit -> (unit -> unit Lwt.t) ref

(** Something that behave like a button, with press, unpress and switch action.
    If [pressed] is true (default false) the button is pressed by default.
    If [button] is present (with some DOM element), this element will be used
    as a button: click on it will trigger actions open or close alternatively.
    If [set] is present, the button will act like a radio button: only one
    with the same set can be opened at the same time.
    Call function [new_set] to create a new set.
    If [closeable_by_button] is false, then the button will open but not close.
    If [closeable_by_method] is false, then the unpress method will have no effect.
    If both are false, the only way to unpress is
    to press another one belonging to the same set.

    Redefine [on_press] and [on_unpress] for your needs.

    Redefine [on_pre_press] [on_post_press] [on_pre_unpress] or [on_post_unpress]
    if you want something to happen just before or after pressing/unpressing.
*)
class button :
     ?set:(unit -> unit Lwt.t) ref
  -> ?pressed:bool
  -> ?closeable_by_method:bool
  -> ?closeable_by_button:bool
  -> ?button:Dom_html.element Js.t
  -> unit
  ->
object
  val mutable press_state : bool

  method private internal_press : unit

  method on_pre_press : unit Lwt.t
  method on_post_press : unit Lwt.t
  method on_pre_unpress : unit Lwt.t
  method on_post_unpress : unit Lwt.t
  method on_press : unit Lwt.t
  method on_unpress : unit Lwt.t
  method pressed : bool
  method press : unit Lwt.t
  method unpress : unit Lwt.t
  method switch : unit Lwt.t
end
