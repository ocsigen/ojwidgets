(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

class type focusable_t = object
  inherit Dom_html.element
  method focus : unit Js.meth
end

module In_button_show_hide_focus_m = struct
  include Button_show_hide.In_button_show_hide_m

  type focus_t = focusable_t Js.t

  let to_focus focus = focus
end

include Button_show_hide_focus_f.Make(In_button_show_hide_focus_m)
