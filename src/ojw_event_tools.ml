(* position / coordinated *)

type position_type = Client | Screen | Page
type touch_type = All_touches | Target_touches | Changed_touches

let get_mouse_ev_coord ?(p_type=Client) ev = match p_type with
  | Client    -> ev##clientX, ev##clientY
  | Screen    -> ev##screenX, ev##screenY
  | Page      ->
    Js.Optdef.case (ev##pageX) (fun () -> 0) (fun x -> x),
    Js.Optdef.case (ev##pageY) (fun () -> 0) (fun y -> y)

let get_touch_coord ?(p_type=Client) ev = match p_type with
  | Client    -> ev##clientX, ev##clientY
  | Screen    -> ev##screenX, ev##screenY
  | Page      -> ev##pageX, ev##pageY

let get_touch_ev_coord ?(t_type=All_touches) idx ?p_type event =
  let item = match t_type with
    | All_touches     -> event##touches##item(idx)
    | Target_touches  -> event##targetTouches##item(idx)
    | Changed_touches -> event##changedTouches##item(idx)
  in
  Js.Optdef.case item (fun () -> (0, 0)) (get_touch_coord ?p_type)

let get_local_mouse_ev_coord dom_elt ?p_type ev =
  let ox, oy = Dom_html.elementClientPosition dom_elt in
  let x, y =  get_mouse_ev_coord ?p_type ev in
  x - ox, y - oy

let get_local_touch_ev_coord dom_elt ?t_type idx ?p_type ev =
  let ox, oy = Dom_html.elementClientPosition dom_elt in
  let x, y =  get_touch_ev_coord ?t_type idx ?p_type ev in
  x - ox, y - oy

let cmp_coord (x1, y1) (x2, y2) = x1 = x2 && y1 = y2

(*** Enable / Disable ***)

let disable_event event html_elt =
  Dom_html.addEventListener html_elt event
    (Dom.handler (fun _ -> Js._false)) Js._true

let enable_event id =
  Dom_html.removeEventListener id

let enable_events ids =
  let rec enable = function
    | id::t   -> enable_event id; enable t
    | []      -> ()
  in enable ids

let disable_drag_and_drop html_elt =
  [disable_event Dom_html.Event.drag html_elt;
   disable_event Dom_html.Event.dragstart html_elt;
   disable_event Dom_html.Event.dragenter html_elt;
   disable_event Dom_html.Event.drop html_elt]
