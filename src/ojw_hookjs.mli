(*
 * Hook
 * Version: 1.1
 * Author: Jordan Singer, Brandon Jacoby, Adam Girton
 * Copyright (c) 2013 - Hook.  All rights reserved.
 * http://www.usehook.com
 *)
(* TODOC The licence is weird, to say the least. *)

(** Binding for hook.js.

  @see < http://www.usehook.com > Hook.js
*)
(* Who is the author of the binding ? *)

type t

class type options =
object
  method reloadPage : bool Js.t Js.writeonly_prop
  method dynamic : bool Js.t Js.writeonly_prop
  method textRequired : bool Js.t Js.writeonly_prop
  method swipeDistance : float Js.t Js.writeonly_prop
  method loaderClass : Js.js_string Js.t Js.writeonly_prop
  method spinnerClass : Js.js_string Js.t Js.writeonly_prop
  method loaderTextClass : Js.js_string Js.t Js.writeonly_prop
  method loaderText : Js.js_string Js.t Js.writeonly_prop
  method reloadEl : (unit -> unit) Js.callback Js.writeonly_prop
end

(** Add a hook to your page. Return the element to be included in your page and the object to initiliaze. *)
val create :
  unit -> Dom_html.divElement Js.t * t

val empty_options : unit -> options Js.t

val init : t -> ?options:(options Js.t) -> unit -> unit

(* TODOC Same as swipe, why two steps here ? *)
