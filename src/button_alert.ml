(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_alert_m = struct
  include Button.In_button_m

  type node_t = Dom_html.element Js.t
  type parent_t = Dom_html.element Js.t

  let to_node node = node
  let to_parent parent = parent

  let default_parent () = (Dom_html.document##body :> Dom_html.element Js.t)
end

include Button_alert_f.Make(In_button_alert_m)
