(* size and orientation *)

type orientation = Portrait | Landscape

val get_screen_size : unit -> int * int

val get_screen_orientation : unit -> orientation

val get_size :
  < clientHeight : < get : int; .. > Js.gen_prop;
    clientWidth : < get : int; .. > Js.gen_prop; .. > Js.t ->
 int * int

val get_document_size : unit -> int * int

(* time *)

val get_timestamp : unit -> float
