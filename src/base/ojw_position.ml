(* Ojwdigets library
   https://github.com/ocsigen/ojwidgets
   Copyright (C) 2013 Charly Chevalier
   Laboratoire PPS - CNRS Université Paris Diderot
  
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, with linking exception;
   either version 2.1 of the License, or (at your option) any later version.
  
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU Lesser General Public License for more details.
  
   You should have received a copy of the GNU Lesser General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

open Dom
open Dom_html
open Ojw_pervasives

type position = [
  | `fixed
  | `absolute
]

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

let attr_of_position = function
  | `fixed -> Js.string "fixed"
  | `absolute -> Js.string "absolute"

let relative_coord
      ?(h : h_orientation = `center)
      ?(v : v_orientation = `center)
      ?(scroll = false)
      ~relative elt =
  let elt' = Ojw_fun.getComputedStyle elt in
  let rel' = Ojw_fun.getComputedStyle relative in
  let rel_w' = Size.get_full_width rel' in
  let rel_h' = Size.get_full_height rel' in
  let elt_w' = Size.get_full_width elt' in
  let elt_h' = Size.get_full_height elt' in
  let s_left, s_top =
    if scroll
    then document##body##scrollLeft, document##body##scrollTop
    else 0, 0
  in
  let calc_h = function
       | `right  -> s_left + rel_w'
       | `left   -> s_left - elt_w'
       | `center -> s_left
  in
  let calc_v = function
       | `bottom -> s_top + rel_h'
       | `top    -> s_top - elt_h'
       | `center -> s_top
  in
  let (hshift,hshift'),(vshift,vshift') =
    (match h with
       | `right  -> (calc_h `right,  calc_h `left)
       | `left   -> (calc_h `left,   calc_h `right)
       | `center -> (calc_h `center, calc_h `center)),
    (match v with
       | `bottom -> (calc_v `bottom, calc_v `top)
       | `top    -> (calc_v `top,    calc_v `bottom)
       | `center -> (calc_v `center, calc_v `center))
  in
  let rect = relative##getBoundingClientRect() in
  let to_side (shift,shift') x =
    let to_int shift = (int_of_float (Js.to_float x)) + shift in
    let integer = to_int shift in
    let integer =
      if integer > 0
      then integer
      else to_int shift'
    in integer
  in (to_side (hshift,hshift') rect##left, to_side (vshift,vshift') rect##top)

let absolute_coord
      ?(h : h_orientation = `center)
      ?(v : v_orientation = `center)
      ?(scroll = false)
      ~relative elt =
  let elt' = Ojw_fun.getComputedStyle elt in
  let rel' = Ojw_fun.getComputedStyle relative in
  let rel_w' = Size.get_full_width rel' in
  let rel_h' = Size.get_full_height rel' in
  let elt_w' = Size.get_full_width elt' in
  let elt_h' = Size.get_full_height elt' in
  let s_left, s_top =
    if scroll
    then document##body##scrollLeft, document##body##scrollTop
    else 0, 0
  in
  let hshift,vshift =
    (match h with
       | `right  -> s_left + rel_w' - elt_w'
       | `left   -> s_left
       | `center -> s_left + (rel_w' / 2) - (elt_w' / 2)),
    (match v with
       | `bottom -> s_top + rel_h' - elt_h'
       | `top    -> s_top
       | `center -> s_top + (rel_h' / 2) - (elt_h' / 2))
  in
  let rect = relative##getBoundingClientRect() in
  let to_side shift x = (int_of_float (Js.to_float x)) + shift in
  (to_side hshift rect##left, to_side vshift rect##top)

let generic_move ?(position = `absolute) (left, top) elt =
  elt##style##top <-  (Ojw_pervasives.pxstring_of_int top);
  elt##style##left <- (Ojw_pervasives.pxstring_of_int left);
  elt##style##position <- attr_of_position position

let relative_move ?h ?v ?scroll ?position ~relative elt =
  generic_move ?position (relative_coord ?v ?h ?scroll ~relative elt) elt

let absolute_move ?h ?v ?scroll ?position ~relative elt =
  generic_move ?position (absolute_coord ?v ?h ?scroll ~relative elt) elt
