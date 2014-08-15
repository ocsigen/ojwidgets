(*
   Swipe 2.0
  
   Arnaud Parant
   Copyright 2013, MIT License
  
 *)

type jq_elt = Ojquery.t
type t = Js.Unsafe.any

class type options =
object
  method startSlide : int Js.t Js.writeonly_prop
  method auto : int Js.t Js.writeonly_prop
  method continous : int Js.t Js.writeonly_prop
  method disableScroll : bool Js.t Js.writeonly_prop
  method stopPropagation : bool Js.t Js.writeonly_prop
  method callback : (int -> 'a -> unit) Js.callback Js.writeonly_prop
  method transitionEnd : (int -> 'a -> unit) Js.callback Js.writeonly_prop
end

let create content =
  let elt = Dom_html.createDiv Dom_html.document in
  elt##className <- Js.string "swipe";
  let wrap_elt = Dom_html.createDiv Dom_html.document in
  elt##className <- Js.string "swipe-wrap";
  Dom.appendChild wrap_elt content;
  Dom.appendChild elt wrap_elt;
  let jq_elt = Ojquery.jQelt elt in
  elt, jq_elt

let empty_options () =
  Js.Unsafe.obj [||]

let null_obj = empty_options ()

let init jq_elt ?(options=null_obj) () =
  let ret = Js.Unsafe.meth_call jq_elt "Swipe" [| Js.Unsafe.inject options |] in
  Js.Unsafe.meth_call ret "data" [| Js.Unsafe.inject (Js.string "Swipe") |]

let start jq_swipe =
  ignore (Js.Unsafe.set (Js.string "window") (Js.string "mySwipe") jq_swipe)

let next jq_swipe =
  ignore (Js.Unsafe.meth_call jq_swipe "next" [||])

let prev jq_swipe =
  ignore (Js.Unsafe.meth_call jq_swipe "prev" [||])

let get_position jq_swipe =
  Js.Unsafe.meth_call jq_swipe "getPos" [||]

let get_number_of_slides jq_swipe =
  Js.Unsafe.meth_call jq_swipe "getNumSlides" [||]

let slide_to jq_swipe index ?(duration=300) () =
  ignore (Js.Unsafe.meth_call jq_swipe "slide"
            [| Js.Unsafe.inject index;
               Js.Unsafe.inject duration |])
