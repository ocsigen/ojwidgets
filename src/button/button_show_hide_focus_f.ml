(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

class type focusable_t = object
  inherit Dom_html.element
  method focus : unit Js.meth
end

module type In = sig
  include Button_show_hide_f.In

  type focus_t

  val to_focus : focus_t -> focusable_t Js.t
end

module Make(M : In) = struct

  class show_hide_focus
    ?set ?pressed
    ?closeable_by_method
    ?closeable_by_button
    ?button
    ?(focused : M.focus_t option)
    (elt : M.showed_elt_t)
    =
  object
    inherit Button_show_hide.show_hide
      ?pressed ?set
      ?closeable_by_method
      ?closeable_by_button
      ?button:(Internals.opt_coerce M.to_button button)
      (M.to_showed_elt elt)
    as super

    method on_post_press =
      lwt () = super#on_post_press in
      let () = match focused with
         | None -> ()
         | Some e -> (M.to_focus e)##focus()
      in
      Lwt.return ()
  end

end
