(** Client debugging functions.*)

(** Create a JS alert message. *)
val alert : string -> unit

(** Create a JS alert message with an int. *)
val alert_int : int -> unit

(** Log a message in the firebug console. *)
val log : string -> unit

(** Log an int in the firebug console. *)
val log_int : int -> unit
