


module Make
    (D : Dom_conv.T)
    (Dropdown : Dropdown_sigs.T
     with module D = D
      and module Button.D = D
      and type Traversable.D.element = D.element
      and type 'a Traversable.D.elt = 'a D.elt)
= struct

  module D = D

  module Dropdown = Dropdown
  module Tr = Dropdown.Traversable
  module Bu = Dropdown.Button

  class type completion = object
    inherit Dropdown.dropdown

    method value : Js.js_string Js.t Js.prop

    method clear : unit Js.meth
    method refresh : unit Js.meth
  end

  class type completion' = object
    inherit completion

    method _clear : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
    method _refresh : (#completion Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  let completion
        ~refresh
        elt elt_traversable =
    let elt' = (Js.Unsafe.coerce (D.to_dom_elt elt) :> completion' Js.t) in
    let meth = Js.wrap_meth_callback in

    ignore (Dropdown.dropdown
              ~focus:false
              elt
              elt_traversable
    );

    let is_traversable _ = Js.to_bool (Js._true) in

    elt'##_refresh <-
    meth (fun this () ->
      let container = (Tr.D.to_dom_elt (elt'##traversable##getContainer())) in
      List.iter
        (Dom.appendChild container)
        (List.map (Tr.D.to_dom_item_elt) (refresh (Js.to_string (elt'##value))))
    );

    elt'##_clear <-
    meth (fun this () ->
       elt'##value <- Js.string "";
       let container = Tr.D.to_dom_elt elt'##traversable##getContainer() in
       let childs = container##childNodes in
       for i=0 to childs##length; do
         Js.Opt.iter (childs##item(i))
           (Dom.removeChild container);
       done;
    );

    Lwt.async (fun () ->
      Bu.pre_presses elt
        (fun _ _ ->
           if (Js.to_string (elt'##value) = "") then
             elt'##prevent(Js._true);
           Lwt.return ()));

    Lwt.async (fun () ->
      Lwt_js_events.inputs (D.to_dom_elt elt)
        (fun _ _ ->
           if (Js.to_string (elt'##value) = "")
           then begin
             elt'##unpress();
             elt'##clear();
           end else begin
             elt'##press();
             elt'##refresh();
           end;
           Lwt.return ()));

    [ elt ; elt_traversable ]
end
