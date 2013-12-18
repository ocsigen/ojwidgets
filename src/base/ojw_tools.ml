open Dom
open Dom_html
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

let as_dom_elt elt f =
  elt##style##visibility <- Js.string "hidden";
  appendChild document##body elt;
  let ret = f elt in
  removeChild document##body elt;
  elt##style##visibility <- Js.string "visible";
  ret

let closeable ?parent ?(close = removeChild) elt =
  elt##classList##add(Js.string "ojw_close");
  let wrap_fun parent =
    (fun super_parent ->
       close
         (Js.Unsafe.coerce super_parent : #element Js.t)
         (Js.Unsafe.coerce parent : #element Js.t))
  in
  match parent with
  | None ->
      (fun () ->
         Js.Opt.iter (elt##parentNode)
           (fun parent ->
              Js.Opt.iter (parent##parentNode) (wrap_fun parent)))
  | Some parent ->
      (fun () ->
         let parent = parent () in
         Js.Opt.iter (parent##parentNode)
           (fun super_parent ->
              Js.Opt.iter (parent##parentNode) (wrap_fun parent)))

let closeable_by_click ?parent ?close elt =
  let f = closeable ?parent ?close elt in
  Lwt.async (fun () ->
      Lwt_js_events.clicks elt
        (fun _ _ ->
           f ();
           Lwt.return ()))
