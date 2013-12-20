(** Various utils. *)

external id : 'a -> 'a = "%identity"

(** De-optize the value. May raise "of_opt"*)
val of_opt : 'a Js.Opt.t -> 'a

(** Extract a suffix of a string. *)
val subs_suffix : string -> int -> string

(** Convert an int into "%i px". *)
val int_of_pxstring : Js.js_string Js.t -> int

(** Extract an int from a string of the form "%i px". *)
val pxstring_of_int : int -> Js.js_string Js.t

(** Size functions for Dom elements. *)
module Size : sig
  val get_full_width :
    ?with_width:bool ->
    ?with_padding:bool ->
    ?with_border:bool -> Dom_html.cssStyleDeclaration Js.t -> int

  val get_full_height :
    ?with_height:bool ->
    ?with_padding:bool ->
    ?with_border:bool -> Dom_html.cssStyleDeclaration Js.t -> int

  val width_height : (int * int) React.signal

  val width : int React.signal

  val height : int React.signal

  (** [set_adaptative_width elt f] will make the width of the element
      recomputed using [f] everytime the width of the window changes. *)
  val set_adaptative_width : Dom_html.element Js.t -> (int -> int) -> unit

  (** [set_adaptative_height elt f] will make the width of the element
      recomputed using [f] everytime the height of the window changes. *)
  val set_adaptative_height : Dom_html.element Js.t -> (int -> int) -> unit

  (** Compute the height of an element to the bottom of the page *)
  val height_to_bottom : int -> Dom_html.element Js.t -> int

  val client_top : Dom_html.element Js.t -> int

  val client_bottom : Dom_html.element Js.t -> int

  val client_left : Dom_html.element Js.t -> int

  val client_right : Dom_html.element Js.t -> int
end

(** Manipulation on option values. *)
module Option :
sig
  (** [map f v] returns the application of f on the option v if v is not None, or None. *)
  val map : ('a -> 'b) -> 'a option -> 'b option

  (** [map_lwt] is like [map] but returns a Lwt value. *)
  val map_lwt : ('a -> 'b Lwt.t) -> 'a option -> 'b option Lwt.t

  (** [iter f v] apply f to v if v is not None. *)
  val iter : ('a -> unit) -> 'a option -> unit

  (** [iter_lwt] is like [iter] but returns a Lwt value. *)
  val iter_lwt : ('a -> unit Lwt.t) -> 'a option -> unit Lwt.t

  (** [lwt_map t f g] If the thread has returned a value v, returns (f v). Else, returns g () *)
  val lwt_map : 'a Lwt.t -> ('a -> 'b) -> (unit -> 'b) -> 'b
end

module List :
sig
  include module type of List

  (** [find_remove f l] takes the first value from the list returning true, and
        returns it (as the 'a). May raise Not_found *)
  val find_remove : ('a -> bool) -> 'a list -> 'a * 'a list

  (** [find_remove k l] takes the first value from the list equal to k, and
        returns it (as the 'a). May raise Not_found *)
  val assoc_remove : 'a -> ('a * 'b) list -> 'b * ('a * 'b) list

  (** Remove duplicates in a sorted list *)
  val uniq : 'a list -> 'a list
end
