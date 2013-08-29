(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module In_button_alert_m = struct
  include Button.In_button_m

  type node_t = Dom_html.element Js.t
  type parent_t = Dom_html.element Js.t

  let of_node node = node
  let to_node node = node
  let to_parent parent = parent

  let default_parent () = (Dom_html.document##body :> Dom_html.element Js.t)
end

include Button_alert_f.Make(In_button_alert_m)

class type alert_t = object
  inherit Button.button_t

  method on_outclick : unit Lwt.t

  method set_parent_node : Dom_html.element Js.t -> unit
  method get_alert_box : Dom_html.element Js.t option
  method get_node : Dom_html.element Js.t list Lwt.t
end

