(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

class button_show_hide
  ?set ?pressed
  ?method_closeable
  ?button_closeable
  ?button
  elt
  =
object
  val mutable display = "block"

  inherit Button.button
        ?pressed ?set
        ?method_closeable
        ?button_closeable
        ?button
        ()

  method on_press =
    elt##style##display <- Js.string display;
    Lwt.return ()

  method on_unpress =
    elt##style##display <- Js.string "none";
    Lwt.return ()

  initializer
  let () = match (Js.to_string elt##style##display) with
    | "none" -> ()
    | d -> display <- d
  in
    if not press_state
    then elt##style##display <- Js.string "none" (*VVV will blink ... *)
end

