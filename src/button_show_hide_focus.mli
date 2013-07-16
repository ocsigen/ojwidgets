(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_show_hide_focus_m
  : Button_show_hide_focus_f.In with type button_t = Dom_html.element Js.t

(** Same as button_show_hide, but also set focus to an element after
    pressed_action.
*)

class type focusable = object
  inherit Dom_html.element
  method focus : unit Js.meth
end

class button_show_hide_focus :
     ?set:(unit -> unit Lwt.t) ref
  -> ?pressed:bool
  -> ?method_closeable:bool
  -> ?button_closeable:bool
  -> ?button:Dom_html.element Js.t
  -> ?focused:focusable Js.t
  -> Dom_html.element Js.t
  ->
object
    inherit Button_show_hide.button_show_hide
end
