  (* OJ Widgets
   * https://github.com/ocsigen/ojwidgets.git
   * Copyright (C) 2013 Arnaud Parant
   * Laboratoire PPS - CNRS Université Paris Diderot
   *
   * This program is free software; you can redistribute it and/or modify
   * it under the terms of the GNU Lesser General Public License as published by
   * the Free Software Foundation, with linking exception;
   * either version 2.1 of the License, or (at your option) any later version.
   *
   * This program is distributed in the hope that it will be useful,
   * but WITHOUT ANY WARRANTY; without even the implied warranty of
   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   * GNU Lesser General Public License for more details.
   *
   * You should have received a copy of the GNU Lesser General Public License
   * along with this program; if not, write to the Free Software
   * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
   *)

open Lwt

let slide_without_start move_events end_event moves_func end_func =
  Lwt.pick [move_events Dom_html.document moves_func;
            end_event Dom_html.document >>= end_func]

let slide_event
    (start_event: #Dom_html.eventTarget Js.t -> 'b Lwt.t)
    slide_without_start
    (dom_elt: #Dom_html.eventTarget Js.t)
    start_func moves_func end_func =

  lwt ev = start_event dom_elt in
  lwt _ = start_func ev in
  slide_without_start moves_func end_func

let slide_events start_events slide_without_start
    dom_elt starts_func moves_func end_func =

  start_events dom_elt (fun ev lt ->
    lwt _ = starts_func ev lt in
    slide_without_start moves_func end_func)

let mouseslide_without_start =
  slide_without_start Lwt_js_events.mousemoves Lwt_js_events.mouseup

let mouseslide (dom_elt: #Dom_html.eventTarget Js.t) =
  slide_event Lwt_js_events.mousedown mouseslide_without_start dom_elt

let mouseslides (dom_elt: #Dom_html.eventTarget Js.t) =
  slide_events Lwt_js_events.mousedowns mouseslide_without_start dom_elt

let touchslide_without_start =
  slide_without_start Lwt_js_events.touchmoves Lwt_js_events.touchend

let touchslide (dom_elt: #Dom_html.eventTarget Js.t) =
  slide_event Lwt_js_events.touchstart touchslide_without_start dom_elt

let touchslides (dom_elt: #Dom_html.eventTarget Js.t) =
  slide_events Lwt_js_events.touchstarts touchslide_without_start dom_elt

type slide_event =
    Touch_event of Dom_html.touchEvent Js.t
  | Mouse_event of Dom_html.mouseEvent Js.t

let get_slide_coord ?t_type idx ?p_type = function
  | Touch_event ev    ->
    Ojw_event_tools.get_touch_ev_coord ?t_type idx ?p_type ev
  | Mouse_event ev    ->
    Ojw_event_tools.get_mouse_ev_coord ?p_type ev

let get_local_slide_coord dom_elt ?t_type idx ?p_type = function
  | Touch_event ev    ->
    Ojw_event_tools.get_local_touch_ev_coord dom_elt ?t_type idx ?p_type ev
  | Mouse_event ev    ->
    Ojw_event_tools.get_local_mouse_ev_coord dom_elt ?p_type ev

let touch_handler func ev = func (Touch_event ev)
let mouse_handler func ev = func (Mouse_event ev)

let touch_or_mouse_start (dom_elt: #Dom_html.eventTarget Js.t) =
  Lwt.pick [Lwt_js_events.touchstart dom_elt >>= (fun ev ->
    Lwt.return (Touch_event ev));
            Lwt_js_events.mousedown dom_elt >>= (fun ev ->
              Lwt.return (Mouse_event ev))]

let touch_or_mouse_without_start event moves_func end_func =
  match event with
    | Touch_event _   -> touchslide_without_start
      (touch_handler moves_func) (touch_handler end_func)
    | Mouse_event _   -> mouseslide_without_start
      (mouse_handler moves_func) (mouse_handler end_func)

let touch_or_mouse_slide (dom_elt: #Dom_html.eventTarget Js.t)
    start_func moves_func end_func =

  lwt event = touch_or_mouse_start dom_elt in
  lwt _ = start_func event in
  touch_or_mouse_without_start event moves_func end_func


let touch_or_mouse_slides (dom_elt: #Dom_html.eventTarget Js.t)
    starts_func moves_func end_func =

  Lwt_js_events.async_loop
    (fun ?use_capture () -> touch_or_mouse_start dom_elt) ()
    (fun ev lt ->
      lwt _ = starts_func ev lt in
    touch_or_mouse_without_start ev moves_func end_func)
