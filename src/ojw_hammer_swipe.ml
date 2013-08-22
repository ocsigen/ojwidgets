(* Hammer.JS - v1.0.6dev - 2013-07-31
 * http://eightmedia.github.com/hammer.js
 *
 * Binding by Arnaud Parant
 * Copyright (c) 2013 Jorik Tangelder <j.tangelder@gmail.com>;
 * Licensed under the MIT license
 *)

(* Fake type to hide js obj type *)
type t = int Js.t

let create panes_list =
  let ul_elt = Dom_html.createUl Dom_html.document in
  ul_elt##className <- Js.string "hsw_conteneur";
  let action e =
    let li_elt = Dom_html.createLi Dom_html.document in
    li_elt##className <- Js.string "hsw_pane";
    Dom.appendChild li_elt e;
    Dom.appendChild ul_elt li_elt
  in
  List.iter action panes_list;
  let carousel_elt = Dom_html.createDiv Dom_html.document in
  carousel_elt##id <- Js.string "carousel";
  Dom.appendChild carousel_elt ul_elt;
  Dom.appendChild Dom_html.document##body carousel_elt;
  (* let jq_carousel = Ojquery.jQelt dom_carousel in *)
  (** it will be better to use jq_carousel, but js code do not allow it. *)
  let carousel = Js.Unsafe.eval_string "new Carousel('#carousel')" in
  carousel

let init carousel =
  ignore (Js.Unsafe.meth_call carousel "init" [||])

let get_current_pane carousel =
  Js.Unsafe.meth_call carousel "getCurrentPane" [||]

let show_pane carousel index =
  let idx = Js.Unsafe.inject index in
  ignore (Js.Unsafe.meth_call carousel "showPane" [| idx |])

let next carousel =
  ignore (Js.Unsafe.meth_call carousel "next" [||])

let prev carousel =
  ignore (Js.Unsafe.meth_call carousel "prev" [||])
