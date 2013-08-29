(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_show_hide_m = struct
  include Button.In_button_m

  type showed_elt_t = Dom_html.element Js.t

  let to_showed_elt selt = selt
end

include Button_show_hide_f.Make(In_button_show_hide_m)

class type show_hide_t = object
  inherit Button.button_t
end
