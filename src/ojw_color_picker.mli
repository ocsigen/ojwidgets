type t

val create : ?width:int -> unit -> t
val append_at : Dom_html.element Js.t -> t -> unit
val init_handler : t -> unit
val get_color : t -> string
