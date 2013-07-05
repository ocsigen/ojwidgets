(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

(** show_hide shows or hides a box when pressed/unpressed.
    Set style property "display: none" for unpressed elements if
    you do not want them to appear shortly when the page is displayed.
*)
class button_show_hide
  ?pressed ?set
  ?method_closeable
  ?button_closeable
  ~button
  elt
  =
object
  val mutable display = "block"

  inherit Button.button
        ?pressed ?set
        ?method_closeable
        ?button_closeable
        ~button
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

