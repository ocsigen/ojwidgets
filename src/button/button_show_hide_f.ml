(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module type In = sig
  include Button_f.In

  type showed_elt_t

  val to_showed_elt : showed_elt_t -> Dom_html.element Js.t
end

module Make(M : In) = struct

  class show_hide
    ?set ?pressed
    ?method_closeable
    ?button_closeable
    ?button
    (elt : M.showed_elt_t)
    =
  object
    val mutable display = "block"

    inherit Button.button
          ?pressed ?set
          ?method_closeable
          ?button_closeable
          ?button:(Internals.opt_coerce M.to_button button)
          ()

    method on_press =
      (M.to_showed_elt elt)##style##display <- Js.string display;
      Lwt.return ()

    method on_unpress =
      (M.to_showed_elt elt)##style##display <- Js.string "none";
      Lwt.return ()

    initializer
    let () = match (Js.to_string (M.to_showed_elt elt)##style##display) with
      | "none" -> ()
      | d -> display <- d
    in
      if not press_state
      then (M.to_showed_elt elt)##style##display <- Js.string "none" (*VVV will blink ... *)
  end

end
