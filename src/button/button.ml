(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_m = struct
  type button_t = Dom_html.element Js.t

  let to_button button = button
end

type radio_set_t = Button_f.radio_set_t

include Button_f.Make(In_button_m)

class type button_t = object
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
