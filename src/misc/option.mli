(** Utils to work with lwt and options *)

(** Syntactic sugar for Lwt.bind *)
val ( >>= ) : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t

(** map f v returns the application of f on the option v if v is not None, or None *)
val map : ('a -> 'b) -> 'a option -> 'b option

(** map_lwt returns a Lwt.value *)
val map_lwt : ('a -> 'b Lwt.t) -> 'a option -> 'b option Lwt.t

(** iter f v apply f to v if v is not None *)
val iter : ('a -> unit) -> 'a option -> unit

(** iter_lwt returns Lwt.return () *)
val iter_lwt : ('a -> unit Lwt.t) -> 'a option -> unit Lwt.t

(** lwt_map t f g. If the thread has returned a value v, returns (f v). Else, returns g () *)
val lwt_map : 'a Lwt.t -> ('a -> 'b) -> (unit -> 'b) -> 'b


module List :
  sig
    (** find_remove f l takes the first value from the list returning true, and
        returns it (as the 'a). May raise Not_found *)
    val find_remove : ('a -> bool) -> 'a list -> 'a * 'a list

    (** find_remove k l takes the first value from the list equal to k, and
        returns it (as the 'a). May raise Not_found *)
    val assoc_remove : 'a -> ('a * 'b) list -> 'b * ('a * 'b) list
    (** Remove duplicates in a sorted list *)
    val uniq : 'a list -> 'a list
  end
external id : 'a -> 'a = "%identity"

(** De-optize the value. May raise "of_opt"*)
val of_opt : 'a Js.Opt.t -> 'a
