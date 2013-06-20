(* Copyright Université Paris Diderot. *)

{client{
open Eliom_content.Html5
open Eliom_content.Html5.F

class type options = object
  method orientation : Js.js_string Js.t Js.writeonly_prop
  method slide : (unit -> unit) Js.callback Js.writeonly_prop
end

let create_empty_options () : options Js.t =
  Js.Unsafe.obj [||]

let set_orientation elt options = function
  | None -> ()
  | Some vertical -> ((if vertical then
                        options##orientation <- (Js.string "vertical")
                      else
                        options##orientation <- (Js.string "horizontal"));
                     ())

let set_on_slide elt f =
  let elt = To_dom.of_element elt in
  let scrollbar = Js.Unsafe.coerce (JQuery.jQelt elt) in
  scrollbar##on(Js.string "slide", Js.wrap_callback (f))

let get_value elt =
  let elt = To_dom.of_element elt in
  let scrollbar = Js.Unsafe.coerce (JQuery.jQelt elt) in
  scrollbar##slider_v(Js.string "value")

let add_slider ?vertical ?slide elt =
  let elt = To_dom.of_element elt in
  let scrollbar = Js.Unsafe.coerce (JQuery.jQelt elt) in
  let options = create_empty_options () in
  set_orientation elt options vertical;
  (match (slide) with
  | Some f -> (options##slide <- (Js.wrap_callback f))
  | None -> ());
  scrollbar##slider(options)
}}
