(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

(** Alert displays an alert box when a button is pressed.
    [get_node] returns the list of elements to be displayed and

    Redefine [get_node] for your needs.

    If you want the alert to be opened at start,
    give an element as [pressed] parameter.
    It must have at the right parent in the page (body by default).

    After getting the node,
    the object is inserted as JS field [o] of the DOM element of
    the alert box.
*)
class button_alert
  ?pressed ?set
  ?method_closeable
  ?button_closeable
  ?(parent_node = (Dom_html.document##body :> Dom_html.element Js.t))
  ?(classes = [])
  ~button
  ()
  =
object(self)
  inherit Button.button
         ?pressed ?set
         ?method_closeable
         ?button_closeable
         ~button
         ()

  val mutable node = None

  method get_node : Dom_html.element Js.t list Lwt.t = Lwt.return []

  method on_press =
    lwt n = self#get_node in
    let d = Dom_html.createDiv Dom_html.document in
    let () = List.iter
               (fun cl -> d##classList##add(Js.string cl))
               ("ojw_alert"::classes)
    in
    d##classList##add(Js.string "ojw_pressed");
    let () = List.iter
               (fun n -> Dom.appendChild d n)
               (n)
    in
    let ud = (Js.Unsafe.coerce d) in
    ud##o <- self;
    node <- Some d;
    Dom.appendChild parent_node d;
    Lwt.return ()

  method on_unpress =
    let () = match node with
      | None -> ()
      | Some n -> try Dom.removeChild parent_node n with _ -> ()
    in
    Lwt.return ()

end

