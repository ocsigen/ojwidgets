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
