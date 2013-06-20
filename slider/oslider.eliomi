{client{
val add_slider : ?vertical:bool -> ?slide:(unit->unit) -> _ Eliom_content.Html5.elt -> unit
val get_value : _ Eliom_content.Html5.elt -> int
val set_on_slide : _ Eliom_content.Html5.elt -> (unit -> unit) -> unit
}}
