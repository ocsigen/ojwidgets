(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

class type focusable = object
  inherit Dom_html.element
  method focus : unit Js.meth
end

class button_show_hide_focus
  ?set ?pressed
  ?method_closeable
  ?button_closeable
  ?button
  ?(focused : focusable Js.t option)
  elt
  =
object
  inherit Button_show_hide.button_show_hide
    ?pressed ?set
    ?method_closeable
    ?button_closeable
    ?button
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
