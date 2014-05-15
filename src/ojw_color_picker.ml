(* Copyright Université Paris Diderot.

   Author : Enguerrand Decorne
*)

type t = (Dom_html.canvasElement Js.t * Dom_html.canvasElement Js.t *
          int * (int * int * int) ref)


let point ctx x y (r, g, b) =
  let pixel = ctx##createImageData(1, 1) in
  let rgbdata = pixel##data in
  Dom_html.pixel_set rgbdata 0 (int_of_float r);
  Dom_html.pixel_set rgbdata 1 (int_of_float g);
  Dom_html.pixel_set rgbdata 2 (int_of_float b);
  Dom_html.pixel_set rgbdata 3 255;
  ctx##putImageData(pixel, x , y)

let hsv_to_rgb h s v =
  let c = v *. s in
  let h1 = h /. 60. in
  let x = c *. (1. -. (abs_float ((mod_float h1 2.) -. 1.))) in
  let m = v -. c in
  let r, g, b =
    match h1 with
    | _ when h1 < 1. -> c,  x,  0.
    | _ when h1 < 2. -> x,  c,  0.
    | _ when h1 < 3. -> 0., c,  x
    | _ when h1 < 4. -> 0., x,  c
    | _ when h1 < 5. -> x,  0., c
    | _ when h1 <= 6. -> c,  0., x
    | _ -> 0., 0., 0.  in
  255. *. (r +. m),
  255. *. (g +. m),
  255. *. (b +. m)

let get_ctx canvas = canvas##getContext (Dom_html._2d_)

let draw_hue ctx width =
  let w = 360. in
  let inc = 360. /. 360. in
  let rec aux i =
      if i >= w then () else
        begin
          let rgb = hsv_to_rgb i 1. 1. in
          for y=0 to 20 do
            point ctx i (float_of_int y) rgb;
          done;
          aux (i +. inc)
        end
  in aux 0.

let draw_sv ctx hue x y size =
  let cur_inc i = (1. /. size) *. i in
  let rec inner_aux s v =
    if s >= size then () else
      begin
        let rgb = hsv_to_rgb hue (cur_inc v) (cur_inc s) in
        point ctx (x +. s) (y +. v) rgb;
        inner_aux (s +. 1.) v
      end
  in let rec aux v =
    if v >= size then () else
      begin
        inner_aux 0. v;
        aux (v +. 1.)
      end in aux 0.

let init_handler (dom_hue, dom_sv, width, color) =
  let get_rgb pixel =
    let r = Dom_html.pixel_get pixel 0 in
    let g = Dom_html.pixel_get pixel 1 in
    let b = Dom_html.pixel_get pixel 2 in
    r, g, b
  in
  let get_coord ev canvas =
    let x, y = Dom_html.elementClientPosition canvas in
    ev##clientX - x,
    ev##clientY - y
  in
  Lwt_js_events.async
  (fun () ->
     Lwt_js_events.clicks dom_sv (fun ev _ ->
         let x, y = get_coord ev dom_sv in
         let ctx = get_ctx dom_sv in
         let rgbdata = ctx##getImageData(x, y, 1, 1)##data in
         let r, g, b = get_rgb rgbdata in
         color := r, g, b;
         Lwt.return ()
      ));
  Lwt_js_events.async
   (fun () ->
     Lwt_js_events.clicks dom_hue (fun ev _ ->
         let x, y = get_coord ev dom_hue in
         let ctx_sv = get_ctx dom_sv in
         draw_sv ctx_sv (float_of_int x) 0. 0. (float_of_int width);
         let ctx_hue = get_ctx dom_hue in
         let rgbdata = ctx_hue##getImageData(x, y, 1, 1)##data in
         let r, g, b = get_rgb rgbdata in
         color := r, g, b;
         Lwt.return ()
      ))

let append_at elt (hue, sv, _, _) =
  let div = Dom_html.createDiv Dom_html.document in
  let div_hue = Dom_html.createDiv Dom_html.document in
  let div_sv = Dom_html.createDiv Dom_html.document in
  Dom.appendChild elt div;
  Dom.appendChild div div_hue;
  Dom.appendChild div div_sv;
  Dom.appendChild div_hue hue;
  Dom.appendChild div_sv sv

let get_rgb (_, _, _, color) =
  !color

let create ?(width = 100) _ =
  let hue = Dom_html.createCanvas Dom_html.document in
  let sv = Dom_html.createCanvas Dom_html.document in
  let color = ref (0, 0, 0) in
  hue##width <- 360;
  sv##width <- width;
  hue##height <- 20;
  sv##height <- width;
  draw_hue (get_ctx hue) width;
  draw_sv (get_ctx sv) 0. 0. 0. (float_of_int width);
  hue, sv, width, color
