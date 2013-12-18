open Dom_html

(** Various utility tools. *)

(** {3 Size and orientation} *)

type orientation = Portrait | Landscape

val get_screen_size : unit -> int * int

val get_screen_orientation : unit -> orientation

val get_size :
  < clientHeight : < get : int; .. > Js.gen_prop;
    clientWidth : < get : int; .. > Js.gen_prop; .. > Js.t ->
 int * int

val get_document_size : unit -> int * int

(** {3 Time} *)

val get_timestamp : unit -> float

(** [as_dom_elt elt f] consider [elt] as an dom element. [elt] is not
  * visible by the user. Using this function let you retrieve informations
  * which are only available when [elt] is inserted into the dom.
  *
  * For example, you can use [elt##style] inside [f] to get real {b width} and
  * real {b heigh} of your element [elt].
  *
  * The [visibilty] css property will be set at [hidden] during this process.
  *)
val as_dom_elt : element Js.t -> (element Js.t -> 'a) -> 'a

val closeable :
     ?parent:(unit -> element Js.t)
  -> ?close:(#element Js.t -> #element Js.t -> unit)
  -> #element Js.t
  -> (unit -> unit)
val closeable_by_click :
     ?parent:(unit -> element Js.t)
  -> ?close:(#element Js.t -> #element Js.t -> unit)
  -> #element Js.t
  -> unit

(* TODOC Do we really need to have three different tools modules ? Can we merge them ? *)
