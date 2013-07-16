(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_show_hide_m = struct
  include Button.In_button_m

  type elt_t = Dom_html.element Js.t

  let to_elt elt = elt
end

include Button_show_hide_f.Make(In_button_show_hide_m)
