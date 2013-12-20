(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

let removeDiacritics (w :Js.js_string Js.t) : Js.js_string Js.t =
  Js.Unsafe.fun_call (Js.Unsafe.variable "removeDiacritics")
    [| Js.Unsafe.inject w |]

let getComputedStyle (elt : #Dom_html.element Js.t) : Dom_html.cssStyleDeclaration Js.t =
  Js.Unsafe.fun_call (Js.Unsafe.variable "getComputedStyle")
    [| Js.Unsafe.inject elt |]

(* TODOC Shouldn't be in tools ? It still need an interface. *)
