(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

module type In = sig
  type button_t

  val to_button : button_t -> Dom_html.element Js.t
end

module Make(M : In) = struct

  type radio_set_t = (unit -> unit Lwt.t) ref
  let new_radio_set () : radio_set_t  = ref (fun () -> Lwt.return ())

  class button
    ?(set : (unit -> unit Lwt.t) ref option)
    ?(pressed = false)
    ?(method_closeable = true)
    ?(button_closeable = true)
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

    method pressed =
      press_state

    method press =
      Firebug.console##log("press !");
      lwt () = match set with
        | None -> Lwt.return ()
        | Some f ->
            if not self#pressed
            then
              (lwt () = !f () in
               f := (fun () -> self#unpress);
               Lwt.return ())
            else Lwt.return ()
      in
      self#internal_press;
      lwt () = self#on_pre_press in
      lwt () = self#on_press in
      self#on_post_press

    method unpress =
      if not method_closeable
      then Lwt.return ()
      else begin
        lwt () = match set with
          | None -> Lwt.return ()
          | Some f ->
              if self#pressed
              then
                (f := (fun () -> Lwt.return ());
                 Lwt.return ())
              else Lwt.return ()
        in
        press_state <- false;
        let () = match button with
          | None -> ()
          | Some b -> (M.to_button b)##classList##remove(Js.string "ojw_pressed");
        in
        lwt () = self#on_pre_unpress in
        lwt () = self#on_unpress in
        self#on_post_unpress
      end

    method switch =
      if not press_state
      then self#press
      else begin
        if button_closeable
        then self#unpress
        else Lwt.return ()
      end

    initializer
      if pressed then begin
        let () = match set with
          | None -> ()
          | Some f -> f := (fun () -> self#unpress);
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
                   (fun e _ -> lwt () = self#switch in Lwt.return ()))

  end

end
