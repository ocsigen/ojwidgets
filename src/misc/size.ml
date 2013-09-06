open Option

(* No: this must be recomputed every time,
   otherwise it won't work after a change page
   -- Vincent
let page = Dom_html.document##documentElement
*)

let get_full_width
      ?(with_width = true)
      ?(with_padding = true)
      ?(with_border = true)
      (elt_style : Dom_html.cssStyleDeclaration Js.t)
  =
  let ifdef b v = if b then v else 0 in
  let open Ojw_unit in
    (ifdef with_width (int_of_pxstring (elt_style##width)))
  + (ifdef with_padding (int_of_pxstring (elt_style##paddingLeft)))
  + (ifdef with_padding (int_of_pxstring (elt_style##paddingRight)))
  + (ifdef with_border (int_of_pxstring (elt_style##borderLeftWidth)))
  + (ifdef with_border (int_of_pxstring (elt_style##borderRightWidth)))

let get_full_height
      ?(with_height = true)
      ?(with_padding = true)
      ?(with_border = true)
      (elt_style : Dom_html.cssStyleDeclaration Js.t)
  =
  let ifdef b v = if b then v else 0 in
  let open Ojw_unit in
    (ifdef with_height (int_of_pxstring (elt_style##height)))
  + (ifdef with_padding (int_of_pxstring (elt_style##paddingTop)))
  + (ifdef with_padding (int_of_pxstring (elt_style##paddingBottom)))
  + (ifdef with_border (int_of_pxstring (elt_style##borderTopWidth)))
  + (ifdef with_border (int_of_pxstring (elt_style##borderBottomWidth)))

let width_height, width, height =
  let page = Dom_html.document##documentElement in
  let wh, set_wh = React.S.create (page##clientWidth, page##clientHeight) in
  Lwt_js_events.(async (fun () -> onresizes
    (fun _ _ ->
      let page = Dom_html.document##documentElement in
      let w = page##clientWidth in
      let h = page##clientHeight in
      set_wh (w, h);
      Lwt.return ()
    )));
  wh,
  (React.S.l1 fst) wh,
  (React.S.l1 snd) wh

(** [set_adaptative_width elt f] will make the width of the element
    recomputed using [f] everytime the width of the window changes. *)
let set_adaptative_width elt f =
  (*VVV Warning: it works only because we do not have weak pointers
    on client side, thus the signal is not garbage collected.
    If Weak is implemented on client side, we must keep a pointer
    on this signal in the element *)
  ignore (React.S.map
            (fun w -> elt##style##width <-
              Js.string (string_of_int (f w)^"px")) height)

(** [set_adaptative_height elt f] will make the width of the element
    recomputed using [f] everytime the height of the window changes. *)
let set_adaptative_height elt f =
  (*VVV see above *)
  ignore
    (React.S.map
       (fun w -> elt##style##height <-
         Js.string (string_of_int (f w)^"px")) height)

(* Compute the height of an element to the bottom of the page *)
let height_to_bottom offset elt =
  let page = Dom_html.document##documentElement in
  let h = page##clientHeight in
  try
    let top = Js.to_float (of_opt (elt##getClientRects()##item(0)))##top in
    h - int_of_float top - offset
  with Failure _ -> h - offset

let client_top elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##top)
let client_bottom elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##bottom)
let client_left elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##left)
let client_right elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##right)
