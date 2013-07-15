(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

let new_radio_set () : (unit -> unit Lwt.t) ref = ref (fun () -> Lwt.return ())

(** Something that behave like a button, with press, unpress and switch action.
    If [pressed] is true (default false) the button is pressed by default.
    If [button] is present (with some DOM element), this element will be used
    as a button: click on it will trigger actions open or close alternatively.
    If [set] is present, the button will act like a radio button: only one
    with the same set can be opened at the same time.
    Call function [new_set] to create a new set.
    If [button_closeable] is false, then the button will open but not close.
    If [method_closeable] is false, then the unpress method will have no effect.
    If both are false, the only way to unpress is
    to press another one belonging to the same set.

    Redefine [on_press] and [on_unpress] for your needs.

    Redefine [on_pre_press] [on_post_press] [on_pre_unpress] or [on_post_unpress]
    if you want something to happen just before or after pressing/unpressing.
*)
class button
  ?(set : (unit -> unit Lwt.t) ref option)
  ?(pressed = false)
  ?(method_closeable = true)
  ?(button_closeable = true)
  ?(button : Dom_html.element Js.t option)
  ()
  =
object(self)
  val mutable press_state = pressed

  method private internal_press =
    press_state <- true;
    match button with
      | None -> ()
      | Some b -> b##classList##add(Js.string "ojw_pressed")

  method on_pre_press = Lwt.return ()
  method on_post_press = Lwt.return ()
  method on_pre_unpress = Lwt.return ()
  method on_post_unpress = Lwt.return ()
  method on_press = Lwt.return ()
  method on_unpress = Lwt.return ()

  method pressed =
    press_state

  method press =
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
        | Some b -> b##classList##remove(Js.string "ojw_pressed");
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
    if pressed then self#internal_press;
    match button with
      | None -> ()
      | Some b ->
          let open Lwt_js_events in
          Lwt.async
            (fun () ->
               clicks b (fun e _ -> lwt () = self#switch in Lwt.return ()))

end
