(* Copyright Université Paris Diderot.
Author : Christophe Lecointe*)

class type slider_utils = object
  method onSlideList : (((unit -> bool) list) ref) Js.prop
end

class type options = object
  method orientation : Js.js_string Js.t Js.writeonly_prop
  method slide : (unit -> unit) Js.callback Js.writeonly_prop
end

let get_slider_utils elt : slider_utils Js.t =
  (Js.Unsafe.coerce elt)##oslider_utils

let set_slider_utils elt =
  let create_slider_utils () = Js.Unsafe.obj [||]
  in
  (Js.Unsafe.coerce elt)##oslider_utils <- (create_slider_utils ())

let get_on_slide_list elt =
  (get_slider_utils elt)##onSlideList

let set_on_slide_list elt value =
  (get_slider_utils elt)##onSlideList <- value

let slide_utils_constructor elt =
  set_slider_utils elt;
  set_on_slide_list elt (ref []);
  ()

let create_empty_options () : options Js.t =
  Js.Unsafe.obj [||]

let set_orientation elt options = function
  | None -> ()
  | Some vertical -> ((if vertical then
                        options##orientation <- (Js.string "vertical")
                      else
                        options##orientation <- (Js.string "horizontal"));
                     ())

let append_callback list f elt =
  let filterFunc f a () = match (Lwt.state a) with
    | Lwt.Fail Lwt.Canceled -> false
    | _ -> f ();
        true in
  let a, _ = Lwt.task () in
  list := (List.rev ((filterFunc f a)::(List.rev (!list))));
  a

let on_slide_ elt f =
  let on_slide = (get_on_slide_list elt) in
  append_callback on_slide f elt

let on_slide elt f =
  on_slide_ elt f

let get_value elt =
  let slider = Js.Unsafe.coerce (Ojquery.js_jQelt elt) in
  slider##slider_v(Js.string "value")

let set_on_slide elt f =
  let scrollbar = Js.Unsafe.coerce (Ojquery.js_jQelt elt) in
  scrollbar##on(Js.string "slide", Js.wrap_callback (f))

let get_value elt =
  let scrollbar = Js.Unsafe.coerce (Ojquery.js_jQelt elt) in
  scrollbar##slider_v(Js.string "value")

let add_slider ?vertical ?slide elt =
  let slider = Js.Unsafe.coerce (Ojquery.js_jQelt elt) in
  let options = create_empty_options () in
  let iter_callbacks list = (Js.wrap_callback
                               (fun () -> (list :=
                                             (List.filter
                                                (fun fon -> fon ())
                                                !list)))) in
  slide_utils_constructor elt;
  set_orientation elt options vertical;
  options##slide <- (iter_callbacks (get_on_slide_list elt));
  (match (slide) with
  | Some f -> ignore (on_slide_ elt f)
  | None -> ());
  slider##slider(options);
  ()
