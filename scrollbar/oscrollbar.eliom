(* Copyright Université Paris Diderot.
Author : Christophe Lecointe*)

{client{
open Size
open Log
open List
open Eliom_content.Html5
open Eliom_content.Html5.F

type scroll_t =
  | Bottom
  | First
  | Int of int
  | Last
  | Left
  | Right
  | Top

class type scrollbar_utils = object
  method lwt_on_scroll : (('a Lwt.t * 'a Lwt.u) ref) Js.prop
  method draggerPos : int Js.prop
  method draggerPct : int Js.prop
  method on_scroll_list : (((unit -> bool) list) ref) Js.prop
  method scroll_start_list : (((unit -> bool) list) ref) Js.prop
  method while_scroll_list : (((unit -> bool) list) ref) Js.prop
end

class type callbacks_options = object
  method onScroll : (unit -> unit) Js.callback Js.writeonly_prop
  method onScrollStart : (unit -> unit) Js.callback Js.writeonly_prop
  method onTotalScroll : (unit -> unit) Js.callback Js.writeonly_prop
  method onTotalScrollBack : (unit -> unit) Js.callback Js.writeonly_prop
  method whileScrolling : (unit -> unit) Js.callback Js.writeonly_prop
  method onTotalScrollOffset : int Js.writeonly_prop
  method onTotalScrollBackOffset : int Js.writeonly_prop
end

class type options = object
  method scrollInertia : int Js.writeonly_prop
  method mouse_wheel_pixels : int Js.writeonly_prop
  method set_height : int Js.writeonly_prop
  method callbacks : callbacks_options Js.t Js.prop
end

let empty_options () : options Js.t =
  let o = Js.Unsafe.obj [||] in
  o##callbacks <- Js.Unsafe.obj [||];
  o

let scroll_to ?scroll elt =
  try
    let a = (Js.Unsafe.coerce elt)##scrollbar in
    (match scroll with
     | None -> ()
     | Some (Int (i : int)) ->
         a##mCustomScrollbar_i(Js.string "scrollTo", i)
     | Some (Bottom as v)
     | Some (Top    as v)
     | Some (Left   as v)
     | Some (Right  as v)
     | Some (First  as v)
     | Some (Last   as v) ->
         let s = match v with
           | Bottom -> "bottom"
           | Top    -> "top"
           | Left   -> "left"
           | Right  -> "right"
           | First  -> "first"
           | Last   -> "last"
           | _ -> ""
         in
         a##mCustomScrollbar_s(Js.string "scrollTo", Js.string s));
    Lwt.return ()
  with _ -> Lwt.return ()

let get_scrollbar_utils elt : scrollbar_utils Js.t =
  (Js.Unsafe.coerce elt)##oscroll_utils

let set_scrollbar_utils elt =
  let create_scrollbar_utils () = Js.Unsafe.obj [||]
  in
  (Js.Unsafe.coerce elt)##oscroll_utils <- (create_scrollbar_utils ())

let set_lwt_on_scroll elt (value : ('a Lwt.t * 'a Lwt.u) ref) =
  (get_scrollbar_utils elt)##lwt_on_scroll <- value

let set_dragger_pos elt value =
  (get_scrollbar_utils elt)##draggerPos <- value

let set_dragger_pct elt value =
  (get_scrollbar_utils elt)##draggerPct <- value

let set_scroll_list elt value =
  (get_scrollbar_utils elt)##on_scroll_list <- value

let get_scroll_list elt =
  (get_scrollbar_utils elt)##on_scroll_list

let set_scroll_start_list elt value =
  (get_scrollbar_utils elt)##scroll_start_list <- value

let get_scroll_start_list elt =
  (get_scrollbar_utils elt)##scroll_start_list

let set_scrolling_list elt value =
  (get_scrollbar_utils elt)##while_scroll_list <- value

let get_scrolling_list elt =
  (get_scrollbar_utils elt)##while_scroll_list

let get_lwt_on_scroll elt : ('a Lwt.t * 'a Lwt.u) ref =
  (get_scrollbar_utils elt)##lwt_on_scroll

let scrollbar_utils_constructor elt =
  set_scrollbar_utils elt;
  set_lwt_on_scroll elt (ref (Lwt.wait ()));
  set_dragger_pos elt 0;
  set_scroll_list elt (ref []);
  set_scroll_start_list elt (ref []);
  set_scrolling_list elt (ref []);
  ()

(** This function returns the position of the dragger. Please be aware that
    the position is updated only when the dragger has finished its movement.
    So if you call it while the dragger is moving, the position returned
    will be the position of the dragger before the scroll **)

let get_dragger_pos elt : int =
  let elt = To_dom.of_element elt in
  (get_scrollbar_utils elt)##draggerPos

(** This function returns the position of the dragger in the bar in percent.
    As above, please be aware that the position is updated only when the
    dragger has finished its movement. **)

let get_dragger_pct elt : int =
  let elt = To_dom.of_element elt in
  (get_scrollbar_utils elt)##draggerPct

(** lwt_scroll_to , as its name suggests, scroll the scrollbar bound
    to elt to a point defined by scroll ([ `Bottom | `First | `Int of int |
    |`Last | `Left | `Right | `Top ]). It returns a thread which end when
    the scrolling is done (immadiately if inertia is desactivated).**)

let lwt_scroll_to ?scroll elt =
  let elt = To_dom.of_element elt in
  ignore (match scroll with
      | None -> scroll_to elt
      | Some s -> scroll_to ~scroll:s elt);
  let lwt_onscroll = get_lwt_on_scroll elt in
  lwt _ = fst !(lwt_onscroll) in
  lwt_onscroll := Lwt.wait();
  Lwt.return ()

let update ?height ?scroll elt =
  try
    let a = (Js.Unsafe.coerce elt)##scrollbar in
    Options.apply_option (fun f -> (Js.Unsafe.coerce elt)##style##height <-
                                     Js.string (string_of_int
                                                  (f elt)^"px")) height;
    a##mCustomScrollbar(Js.string "update");
    scroll_to ?scroll elt
  with e -> log ("scroll update error: "^Printexc.to_string e); Lwt.return ()

let add =
  let t = ref [] in
  ignore
    (React.S.map
       (fun _ ->
          Lwt.async (fun () ->
              Lwt_list.iter_p (fun (scroll, height, elt) ->
                  lwt () = Lwt_js_events.request_animation_frame () in
                  update ?height ?scroll elt) !t))
       Size.width_height);
  fun ?height ?scroll elt ->
    match scroll, height with
    | None, None -> ()
    | _ -> t := (scroll, height, elt)::!t

let stop_scroll_wait elt () =
  let lwt_onscroll = (get_lwt_on_scroll elt) in
  Lwt.wakeup (snd !lwt_onscroll) ();
  match (Lwt.state (fst !lwt_onscroll)) with
  | Lwt.Return () -> lwt_onscroll := Lwt.wait ()
  | _ -> ()

let append_callback list f elt =
  let filterFunc f a () = match (Lwt.state a) with
    | Lwt.Fail Lwt.Canceled -> false
    | _ -> f ();
        true in
  let a, _ = Lwt.task () in
  list := (List.rev ((filterFunc f a)::(List.rev (!list))));
  a

(** This function adds a function to the list of function to do when
    the "scrolling" event is triggered.**)

let while_scrolling_ f elt =
  let while_scrolling = (get_scrolling_list elt) in
  append_callback while_scrolling f elt

let while_scrolling f elt =
  let elt = To_dom.of_element elt in
  while_scrolling_ f elt

(** This function adds a function to the list of function to do when
    the "Scroll Start" event is triggered.**)

let scroll_starts_ f elt =
  let scroll_start = (get_scroll_start_list elt) in
  append_callback scroll_start f elt

let scroll_starts f elt =
  let elt = To_dom.of_element elt in
  scroll_starts_ f elt

(** This function adds a function to the list of function to do when the
    "on_scroll" callback is triggered. The function is added at the back of
    the list, and thus will be called last during the callback.
    (until you add an other one of course) **)

let scrolls_ f elt =
  let on_scroll = (get_scroll_list elt) in
  append_callback on_scroll f elt

let scrolls f elt =
  let elt = To_dom.of_element elt in
  scrolls_ f elt

(** This function add a customScrollbar to the element elt. There are
      several optionnal arguments (to have the full details, see the doc
      of the js lib used :
      http://manos.malihu.gr/jquery-custom-content-scroller/)

      - height determine the height of the scrollbar. If none, the
      scrollbar will have the size of the element

      - scroll, of type [ `Bottom | `First | `Int of int | `Last
                           | `Left | `Right | `Top ]. Determine the
      starting position of the scroll.

      - Inertia : scrolling inertia in milliseconds. Really low
      values (<10) are forced to 10, because it breaks the scrollbar when
      under 10. Low values are irrelevant anyway, since the user can't
      even see it. To disable the inertia, put 0.

      - mouseWheelPixel : Mouse wheel scrolling amount in pixel. If
      undefined , the value "auto" is used.

      Different callback are also available, if you want to implement them :

      on_scroll is called at the end of a scroll. The scroll end when
      the dragger stops moving.

      on_scroll_start is called before every scroll.

      on_total_scroll is called when the scrollbar end-limit is
      reached. The end-limit can be set with the parameter
      on_total_scroll_offset, and is the end of the content by default.

      on_total_scroll_back is called when scrollbar beginning is
      reache. The beginning limit can be set with the parameter
      on_total_scroll_back_offset, and is the beginning of the content by default.

      while_scrolling is triggered during scrolling.
   **)

let add_scrollbar
    ?height
    ?scroll
    ?(inertia = 1000)
    ?mouse_wheel_pixels
    ?on_scroll_callback
    ?on_scroll_start_callback
    ?on_total_scroll_callback
    ?on_total_scroll_back_callback
    ?while_scrolling_callback
    ?on_total_scroll_offset
    ?on_total_scroll_back_offset
    elt =


  let de_optize_callback callback = Js.wrap_callback (match callback with
      | None -> (fun () -> ())
      | Some f -> f) in
  let elt = To_dom.of_element elt in
  let iter_callbacks list = (Js.wrap_callback
                               (fun () -> (list :=
                                             (List.filter (fun fon -> fon ())
                                                !list)))) in
  let scrollbar = Js.Unsafe.coerce (JQuery.jQelt elt) in
  (Js.Unsafe.coerce elt)##scrollbar <- scrollbar;
  scrollbar_utils_constructor elt;
  lwt () = Lwt_js_events.request_animation_frame () in
  let options = empty_options () in
  options##scrollInertia <- (match inertia with
      | 0 -> 0
      | x when x < 10 -> 10
      | _ -> inertia);
  (match mouse_wheel_pixels with
   | None -> ()
   | Some x ->     options##mouse_wheel_pixels <- x);
  (match height with
   | None -> ()
   | Some f ->
       (Js.Unsafe.coerce elt)##style##height <-
         Js.string (string_of_int (f elt)^"px");
       options##set_height <- f elt);
  options##callbacks##onScroll <- (iter_callbacks (get_scroll_list elt));
  ignore (scrolls_ (stop_scroll_wait elt) elt);
  ignore (scrolls_ (fun () -> set_dragger_pos elt
                       (Js.Unsafe.eval_string "mcs.draggerTop")) elt);
  ignore (scrolls_ (fun () -> set_dragger_pct elt
                       (Js.Unsafe.eval_string "mcs.topPct")) elt);
  options##callbacks##onScrollStart <-
    (iter_callbacks (get_scroll_start_list elt));
  options##callbacks##whileScrolling <-
    (iter_callbacks (get_scrolling_list elt));
  (match on_scroll_callback with
   | None -> ()
   | Some f -> ignore (scrolls_ f elt));
  (match on_scroll_start_callback with
   | None -> ()
   | Some f -> ignore (scroll_starts_ f elt));
  (match while_scrolling_callback with
   | None -> ()
   | Some f -> ignore (while_scrolling_ f elt));
  options##callbacks##onTotalScroll <- (de_optize_callback
                                          on_total_scroll_callback);
  options##callbacks##onTotalScrollBack <- (de_optize_callback
                                              on_total_scroll_back_callback);
  (match on_total_scroll_offset with
   | None -> ()
   | Some x -> options##callbacks##onTotalScrollOffset <- x);
  (match on_total_scroll_back_offset with
   | None -> ()
   | Some x -> options##callbacks##onTotalScrollBackOffset <- x);
  scrollbar##mCustomScrollbar(options);
  if scroll <> None || height <> None
  then begin
    add ?scroll ?height elt;
    scroll_to ?scroll elt
  end
  else Lwt.return ()
}}
