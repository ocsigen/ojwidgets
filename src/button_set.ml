(* Copyright Université Paris Diderot.

   Author : Vincent Balat
            Charly Chevalier
*)

(** Buttons may belong to a [button_set]. A set will close the last opened
  * button if another one is going to be opened (actually, like radio button).
  * There are four callbacks to define which correspond to the different steps
  * of a button swap.
  * [on_first] will be called when there is no button pressed
  * [on_same] will be called when the same button is pressed again
  * [on_open] will be called when a new button is pressed
  * [on_close] will bew called when a button is unpressed
  *)

class ['a] button_set
  ~(on_first : 'a -> unit Lwt.t)
  ~(on_same : 'a -> unit Lwt.t)
  ~(on_open : 'a -> unit Lwt.t)
  ~(on_close : 'a -> unit Lwt.t)
  =
object(self)
  val mutable current : 'a option = None

  method private set handler =
    current <- Some handler

  method get : 'a option =
    current

  method update (handler : 'a) =
    lwt () =
      match self#get with
        | None ->
            self#set handler;
            on_first handler;
        | Some (current_handler) ->
            if current_handler = handler
            then on_same handler
            else begin
              lwt () = on_close current_handler in
              self#set handler;
              on_open handler;
            end
    in Lwt.return ()

end
