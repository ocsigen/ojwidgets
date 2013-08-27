(* size and orientation *)

type orientation = Portrait | Landscape

let get_screen_size () =
  let scr = Dom_html.window##screen in
  scr##width, scr##height

let get_screen_orientation () =
  let width, height = get_screen_size () in
  if (width <= height) then Portrait else Landscape

let get_size dom_html =
  dom_html##clientWidth, dom_html##clientHeight

let get_document_size () =
  get_size Dom_html.document##documentElement

(* time *)

let get_timestamp () =
  let date = jsnew Js.date_now () in
  Js.to_float (date##getTime ())
