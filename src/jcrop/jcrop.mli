(*
 * Copyright (c) 2011 Tapmodo Interactive LLC,
 * http://github.com/tapmodo/Jcrop

 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:

 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *)

(*
 * Author: Charly Chevalier
 * *)

(* Type used to constraint usage of parameters of Jcrop's callbacks *)
class type param = object
  method x : int Js.readonly_prop
  method x2 : int Js.readonly_prop
  method y : int Js.readonly_prop
  method y2 : int Js.readonly_prop
  method h : int Js.readonly_prop
  method w : int Js.readonly_prop
end

(** Jcrop gives you crop tools to redefine an <img> tag. You have to pass
  * this image as parameter to apply tools on it.
  *
  * This ocaml class is a binding of this JQuery plugin. (see
  * http://deepliquid.com/content/Jcrop.html for the original javacript
  * code).
  *
  * There are some parameters to configure the tools. (description come from
  * the original website):
  * @param on_select called when selection is completed
  * @param on_change called when the selection is moving
  * Jcrop has a sense of state, whether there is an active selection or not.
  * To detect when the interface is released, there is also a handler for
  * these events:
  * @param on_release called when the selection is released
  * @param aspect_ratio aspect ratio of w/h (e.g. 1 for square)
  * @param min_size minimum width/height, use 0 for unbounded dimension
  * @param max_size maximum width/height, use 0 for unbounded dimension
  * @param set_select set an initial selection area
  * @param bg_color set color of background container (default: "black")
  * @param bg_opacity Opacity of outer image when cropping (default: 0.6)
  * *)
class jcrop :
     ?on_select:(param Js.t -> unit)
  -> ?on_change:(param Js.t -> unit)
  -> ?on_release:(param Js.t -> unit)
  -> ?aspect_ratio:float
  -> ?min_size:(int * int)
  -> ?max_size:(int * int)
  -> ?set_select:(int * int * int * int)
  -> ?bg_color:string
  -> ?bg_opacity:float
  -> Dom_html.imageElement Js.t
  ->
object
end
