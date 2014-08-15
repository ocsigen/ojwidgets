(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

open Dom
open Dom_html

let global_bg = ref (None : divElement Js.t option)

let get_global_bg () =
  let update_bg bg =
    let w, h =
      let w, h = Ojw_tools.get_screen_size () in
      Js.Optdef.case (window##innerWidth)
        (fun () -> w)
        (fun w -> w),
      Js.Optdef.case (window##innerHeight)
        (fun () -> h)
        (fun h -> h)
    in
    bg##style##height <- Ojw_pervasives.pxstring_of_int h;
    bg##style##width <- Ojw_pervasives.pxstring_of_int w;
  in
  match !global_bg with
    | Some bg ->
        update_bg bg;
        bg
    | None ->
        let bg = createDiv Dom_html.document in
        bg##classList##add(Js.string "ojw_background");
        global_bg := Some bg;
        update_bg bg;
        appendChild document##body bg;
        bg

module Style = struct
  let popup_cls = "ojw_popup"
end

module Make
    (D : Ojw_dom_sigs.T)
    (Alert : Ojw_alert_sigs.T
     with type D.element = D.element
      and type 'a D.elt = 'a D.elt)
= struct
  exception Close_button_not_in_popup

  module D = D
  module Alert = Alert

  let show_background () =
    (get_global_bg ())##style##visibility <- Js.string "visible"

  let hide_background () =
    (get_global_bg ())##style##visibility <- Js.string "hidden"

  let define_popup ~bg ?(with_background = true) elt =
    (D.to_dom_elt elt)##classList##add(Js.string Style.popup_cls);

    Lwt.async (fun () ->
      Alert.shows elt
        (fun _ _ ->
           if with_background then
             show_background ();
           Lwt.return ()));

    Lwt.async (fun () ->
      Alert.hides elt
        (fun _ _ ->
           if with_background then (
             Ojw_log.log "with bg";
             hide_background ();
           );
           Lwt.return ()))

  let popup ?show ?allow_outer_clicks ?with_background elt =
    let bg = get_global_bg () in
    let before elt =
      Ojw_position.absolute_move
        ~h:`center ~v:`center ~scroll:false ~position:`fixed
        ~relative:bg (Alert.D.to_dom_elt elt);
    in

    define_popup ?with_background ~bg elt;
    ignore (Alert.alert ~before ?show ?allow_outer_clicks elt);

    elt

  let dyn_popup ?show ?allow_outer_clicks ?with_background elt f =
    let bg = get_global_bg () in
    let before elt =
      Ojw_position.absolute_move
        ~h:`center ~v:`center ~scroll:false ~position:`fixed
        ~relative:bg (Alert.D.to_dom_elt elt);
      Lwt.return ()
    in

    define_popup ?with_background ~bg elt;
    ignore (Alert.dyn_alert ~before ?show ?allow_outer_clicks elt f);

    elt

  let closeable_by_click = Alert.closeable_by_click

  let to_popup = Alert.to_alert
  let to_dyn_popup = Alert.to_dyn_alert
end
