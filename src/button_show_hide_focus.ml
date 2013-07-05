(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

(** Same as button_show_hide, but also set focus to an element after
    pressed_action.
*)

class button_show_hide_focus
  ?pressed ?set
  ?method_closeable
  ?button_closeable
  ?focused
  ~button
  elt
  =
object
  inherit Button_show_hide.button_show_hide
    ?pressed ?set
    ?method_closeable
    ?button_closeable
    ~button
    elt
  as super

  method on_post_press =
    lwt () = super#on_post_press in
    let () = match focused with
       | None -> ()
       | Some e -> e##focus()
    in
    Lwt.return ()
end
