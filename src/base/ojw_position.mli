(* Ojwidgets library
   https://github.com/ocsigen/Ojwidgets
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


(** Positions helper for javascript elements
   
    This module provides some helpers to get coordinates or move element
    next to each others.
   
    @author Charly Chevalier
   
  *)

open Dom
open Dom_html

(** The type to determin the value of the position attribute of the javascript
    element. *)
type position = [
  | `fixed
  | `absolute
]

(** The type used by vertical and horizontal orientation *)
type common_orientation = [
  | `center
]
(** The type for horizontal orientation. *)
type h_orientation = [
  | `right
  | `left
  | common_orientation
]
(** The type for vertical orientation. *)
type v_orientation = [
  | `bottom
  | `top
  | common_orientation
]

(** [relative_coord ?h ?v ~relative elt] try to calculate the
    coordinates of [elt] applying the directions [h] and [v] on it and using
    [relative] as a reference. {b [elt] will be placed outside of [relative].}
   
    If the given orientation move [elt] out of screen, the orientation is flip
    to the opposite.
  *)
val relative_coord :
     ?h:h_orientation
  -> ?v:v_orientation
  -> ?scroll:bool
  -> relative:#element Js.t
  -> #element Js.t
  -> (int * int)

(** [relative_move ?h ?v ~relative elt] same as [relative_coord], but instead
    of returning coordinates, it moves directly [elt] to the calculated
    coordinates.
    *)
val relative_move :
     ?h:h_orientation
  -> ?v:v_orientation
  -> ?scroll:bool
  -> ?position:position
  -> relative:#element Js.t
  -> #element Js.t
  -> unit

(** [absolute_coord ?h ?v ~relative elt] same as [relative_coord], but instead
    of placing [elt] outside of [relative], it place {b inside}.
  *)
val absolute_coord :
     ?h:h_orientation
  -> ?v:v_orientation
  -> ?scroll:bool
  -> relative:#element Js.t
  -> #element Js.t
  -> (int * int)

(** [absolute_move ?h ?v ~relative elt] same as [absolute_coord], but instead
    of returning coordinates, it moves directly [elt] to the calculated
    coordinates.
    *)
val absolute_move :
     ?h:h_orientation
  -> ?v:v_orientation
  -> ?scroll:bool
  -> ?position:position
  -> relative:#element Js.t
  -> #element Js.t
  -> unit
