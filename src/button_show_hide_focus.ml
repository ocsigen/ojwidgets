(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

class type focusable = object
  inherit Dom_html.element
  method focus : unit Js.meth
end

module In_button_show_hide_focus_m = struct
  include Button_show_hide.In_button_show_hide_m

  type showed_elt_t = Dom_html.element Js.t
  type focus_t = focusable Js.t

  let to_showed_elt selt = selt
  let to_focus focus = focus
end

include Button_show_hide_focus_f.Make(In_button_show_hide_focus_m)
