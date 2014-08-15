(*
   Hook
   Version: 1.1
   Author: Jordan Singer, Brandon Jacoby, Adam Girton
   Copyright (c) 2013 - Hook.  All rights reserved.
   http://www.usehook.com
 *)

type t = Ojquery.t

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

let create () =
  let hook_elt = Dom_html.createDiv Dom_html.document in
  hook_elt##className <- Js.string "hook";
  hook_elt##id <- Js.string "hook";
  let jq_elt = Ojquery.jQelt hook_elt in
  hook_elt, jq_elt

let empty_options () =
  Js.Unsafe.obj [||]

let null_obj = empty_options ()

let init jq_elt ?(options=null_obj) () =
  Lwt.async (fun () -> Lwt.return (ignore (Js.Unsafe.meth_call jq_elt "hook" [| Js.Unsafe.inject options |])))
