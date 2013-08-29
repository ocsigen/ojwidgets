(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module type In = sig
  type button_t

  val to_button : button_t -> Dom_html.element Js.t
end

type radio_set_t = (unit -> unit Lwt.t) ref

module Make(M : In) = struct

  let new_radio_set () : radio_set_t = ref (fun () -> Lwt.return ())

  class button
    ?(set : (unit -> unit Lwt.t) ref option)
    ?(pressed = false)
    ?(closeable_by_method = true)
    ?(closeable_by_button = true)
    ?(button : M.button_t option)
    ()
    =
  object(self)

    val mutable press_state = pressed

    method private internal_press =
      press_state <- true;
      match button with
        | None -> ()
        | Some b -> (M.to_button b)##classList##add(Js.string "ojw_pressed")

    method on_pre_press = Lwt.return ()
    method on_post_press = Lwt.return ()
    method on_pre_unpress = Lwt.return ()
    method on_post_unpress = Lwt.return ()
    method on_press = Lwt.return ()
    method on_unpress = Lwt.return ()

    method pressed = press_state

    method press =
      lwt () = match set with
        | None -> Lwt.return ()
        | Some f -> if not self#pressed
          then (lwt () = !f () in
                f := (fun () -> self#really_unpress);
                Lwt.return ())
          else Lwt.return ()
      in
      self#internal_press;
      lwt () = self#on_pre_press in
      lwt () = self#on_press in
      self#on_post_press

    method private really_unpress =
      (match set with
        | None -> ()
        | Some f -> if self#pressed then f := Lwt.return else ());
      press_state <- false;
      let () = match button with
        | None -> ()
        | Some b -> (M.to_button b)##classList##remove(Js.string "ojw_pressed");
      in
      lwt () = self#on_pre_unpress in
      lwt () = self#on_unpress in
      self#on_post_unpress

    method unpress =
      if closeable_by_method then self#really_unpress else Lwt.return ()

    method switch = if press_state then self#press else self#unpress

    method private button_switch =
      if not press_state
      then self#press
      else if closeable_by_button then self#really_unpress else Lwt.return ()

    initializer
      if pressed then begin
        let () = match set with
          | None -> ()
          | Some f -> f := (fun () -> self#really_unpress);
        in
        self#internal_press;
      end;
      match button with
        | None -> ()
        | Some b ->
            let open Lwt_js_events in
            Lwt.async
              (fun () ->
                 clicks (M.to_button b)
                   (fun e _ ->
                      Dom.preventDefault e;
                      Dom_html.stopPropagation e;
                      self#button_switch))

  end

end
