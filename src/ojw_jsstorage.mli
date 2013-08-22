(* Copyright Université Paris Diderot.

   Author : Arnaud Parant
*)

module type JSSTORAGE =
  sig

    type t
    type 'a key

    (** If storage does not existe,
        It launch failwith "Storage is not available" *)
    val get : unit -> t

    val length : t -> int

    (** [create_key name json_type] *)
    val create_key : string -> 'a Deriving_Json.t -> 'a key

    (** [get_name_key storage index] *)
    val get_name_key : t -> int -> string option

    val get_item : t -> 'a key -> 'a option

    (** [get_noopt_item storage key json_type default_value] *)
    val get_noopt_item : t -> 'a key -> 'a -> 'a

    val set_item : t -> 'a key -> 'a -> unit

    val remove_item : t -> 'a key -> unit

    val clear : t -> unit

  end

module SessionStorage : JSSTORAGE

module LocalStorage : JSSTORAGE
