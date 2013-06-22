(* Copyright Université Paris Diderot. *)

(** 
  A drag&drop widget using Html5 drag&drop API.
  @author : Gabriel Radanne
*)

(**
  The widget is parametrized by a list of draggables and dropzones. 
  The draggables can be dragged around and dropped in a dropzone.
  When the draggable is dropped, it's remove from his old dropzone and added to the new one.
*)

val init : 
  ?drop_callback:('dropinfo -> 'draginfo -> unit Lwt.t) ->
  ?label:string ->
  ?over_class:string ->
  ((#Dom_html.element as 'drag) Js.t * 'draginfo) list -> 
  (#Dom_html.element Js.t * ('drag Js.t -> 'draginfo -> unit) * 'dropinfo) list -> 
  unit
(**
   [ init draggables dropzones ] will initialize everything.
   The first contains pairs of an html element to be dragged and some information.
   The second list contains the html element, an update function that takes the newly dragged element and his information and some other info.

   [ ~label ] is used to personalized the internal drag&drop label. The default one is "text/id" where id is a random string.

   [ ~over_class ] is added to the class array of a dropzone when it's hovered by a draggable.
  
   [ ~drop_callback ] is called when a drop occurs. 
   The function is given the information attached to the draggable and the dropzone 
*)
