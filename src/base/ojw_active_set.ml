module type T = sig
  class type item = object
    inherit Dom_html.element

    method enable : unit Js.meth
    method disable : unit Js.meth
  end

  class type item' = object
    inherit item

    method _enable : (#item Js.t, unit -> unit) Js.meth_callback Js.prop
    method _disable : (#item Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  type t

  val set : ?at_least_one : bool -> unit -> t

  val enable : set:t -> #item Js.t -> unit
  val disable : set:t -> #item Js.t -> unit

  val ctor :
       enable : (#item Js.t -> unit -> unit)
    -> disable : (#item Js.t -> unit -> unit)
    -> #item' Js.t
    -> item Js.t
end

class type item = object
  inherit Dom_html.element

  method enable : unit Js.meth
  method disable : unit Js.meth
end

class type item' = object
  inherit item

  method _enable : (#item Js.t, unit -> unit) Js.meth_callback Js.prop
  method _disable : (#item Js.t, unit -> unit) Js.meth_callback Js.prop
end

type t = {
  at_least_one : bool;
  mutable active : item Js.t option;
}

let set ?(at_least_one = false) () = {
    at_least_one;
    active = None;
  }

let enable ~set it =
  (match set.active with
   | None -> ()
   | Some active -> active##disable());
  it##enable();
  set.active <- Some (Js.Unsafe.coerce it :> item Js.t)

let disable ~set it =
  if set.at_least_one
  then (())
  else
    (it##disable();
     set.active <- None)

let ctor
    ~(enable : (#item Js.t -> unit -> unit))
    ~(disable : (#item Js.t -> unit -> unit))
    (elt : #item' Js.t) =
  let elt' = (Js.Unsafe.coerce elt :> item' Js.t) in
  let meth = Js.wrap_meth_callback in
  elt'##_enable <- meth enable;
  elt'##_disable <- meth disable;
  (elt' :> item Js.t)
