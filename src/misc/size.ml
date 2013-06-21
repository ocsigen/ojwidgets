open Options

let page = Dom_html.document##documentElement

module Size = struct
  let width_height, width, height =
    let wh, set_wh = React.S.create (page##clientWidth, page##clientHeight) in
    Lwt_js_events.(async (fun () -> onresizes
      (fun _ _ ->
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
  let height_to_bottom elt =
    let h = page##clientHeight in
    try
      let top = Js.to_float (of_opt (elt##getClientRects()##item(0)))##top in
      h - int_of_float top - 10
    with Failure _ -> h - 10

end

let client_top elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##top)
let client_bottom elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##bottom)
let client_left elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##left)
let client_right elt =
  int_of_float (Js.to_float elt##getBoundingClientRect()##right)
