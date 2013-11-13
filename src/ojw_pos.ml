(* Ojwdigets library
 * https://github.com/ocsigen/ojwidgets
 * Copyright (C) 2013 Charly Chevalier
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

open Dom
open Dom_html

type common_orientation = [
  | `center
]
type h_orientation = [
  | `right
  | `left
  | common_orientation
]
type v_orientation = [
  | `bottom
  | `top
  | common_orientation
]

let relative_coord
      ?(h : h_orientation = `center)
      ?(v : v_orientation = `center)
      ~relative elt =
  let elt' = Ojw_fun.getComputedStyle elt in
  let rel' = Ojw_fun.getComputedStyle relative in
  let rel_w' = Ojw_misc.get_full_width rel' in
  let rel_h' = Ojw_misc.get_full_height rel' in
  let elt_w' = Ojw_misc.get_full_width elt' in
  let elt_h' = Ojw_misc.get_full_height elt' in
  let s_left = document##body##scrollLeft in
  let s_top = document##body##scrollTop in
  let (hshift,hshift'),(vshift,vshift') =
    (match h with
       | `right -> (s_left + rel_w', s_left - elt_w')
       | `left  -> (s_left - elt_w', s_left + rel_w')
       | `center -> (s_left, s_left)),
    (match v with
       | `bottom -> (s_top + rel_h', s_top - elt_h')
       | `top    -> (s_top - elt_h', s_top + rel_h')
       | `center -> (s_top, s_top))
  in
  Js.Opt.case (relative##getClientRects()##item(0))
    (fun rect -> (0, 0))
    (fun rect ->
       let to_side (shift,shift') x =
         let to_int shift = (int_of_float (Js.to_float x)) + shift in
         let integer = to_int shift in
         let integer =
           if integer > 0
           then integer
           else to_int shift'
         in integer
       in (to_side (hshift,hshift') rect##left, to_side (vshift,vshift') rect##top))

let relative_move ?h ?v ~relative elt =
  let container_left, container_top = relative_coord ?v ?h ~relative elt in
  elt##style##top <- (Ojw_unit.pxstring_of_int container_top);
  elt##style##left <- (Ojw_unit.pxstring_of_int container_left);
  elt##style##position <- Js.string "absolute"
