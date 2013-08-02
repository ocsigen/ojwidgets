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

(* Object to simulate Jcrop parameters on creation of the widget *)
class type options = object
  method aspectRatio : float Js.writeonly_prop
  method minSize : (int * int) Js.writeonly_prop
  method maxSize : (int * int) Js.writeonly_prop
  method setSelect : (int * int * int * int) Js.writeonly_prop
  method bgColor : string Js.writeonly_prop
  method bgOpacity : float Js.writeonly_prop
  method onSelect : (param Js.t -> unit) Js.callback Js.writeonly_prop
  method onChange : (param Js.t -> unit) Js.callback Js.writeonly_prop
  method onRelease : (param Js.t -> unit) Js.callback Js.writeonly_prop
end

class jcrop
  ?on_select
  ?on_change
  ?on_release
  ?aspect_ratio
  ?min_size
  ?max_size
  ?set_select
  ?(bg_color = "black")
  ?(bg_opacity = 0.6)
  (elt : Dom_html.imageElement Js.t)
  =
let wrap_callback cb =
  Js.wrap_callback
    (fun c ->
       cb ((Js.Unsafe.coerce c) :> param Js.t))
in
object(self)
  initializer
  (* Create default object for options *)
  let opt = (Js.Unsafe.obj [||] :> options Js.t) in
  let open Ojw_misc in

  Option.iter (fun ov -> opt##onSelect <- wrap_callback ov) on_select;
  Option.iter (fun ov -> opt##onChange <- wrap_callback ov) on_change;
  Option.iter (fun ov -> opt##onRelease <- wrap_callback ov) on_release;

  Option.iter (fun ov -> opt##aspectRatio <- ov) aspect_ratio;
  Option.iter (fun ov -> opt##setSelect <- ov) set_select;
  Option.iter (fun ov -> opt##minSize <- ov) min_size;
  Option.iter (fun ov -> opt##maxSize <- ov) max_size;

  opt##bgColor <- bg_color;
  opt##bgOpacity <- bg_opacity;

  let img =
    Js.Unsafe.coerce (Ojquery.js_jQelt (elt :> Dom_html.element Js.t))
  in
  (* We can't use the extension syntax of jsoo, because Jcrop is not a valid
   * identifier, so we use meth_call instead. *)
  (Js.Unsafe.meth_call img "Jcrop" [| Js.Unsafe.inject opt |])
end
