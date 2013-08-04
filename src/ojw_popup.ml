(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

let global_bg : Dom_html.divElement Js.t option ref = ref None

let get_global_bg () =
  match !global_bg with
    | Some bg -> bg
    | None ->
        let bg = Dom_html.createDiv Dom_html.document in
        let () = bg##classList##add(Js.string "ojw_background") in
        global_bg := Some bg;
        bg

let div ?cls content =
  let d = Dom_html.createDiv Dom_html.document in
  let () =
    match cls with
      | None -> ()
      | Some cl -> d##classList##add(Js.string cl)
  in
  List.iter (fun elt -> Dom.appendChild d elt) content;
  d

class popup
  ?(width = 500)
  ?(close_button = true)
  ?(with_background = true)
  ?(header : Dom_html.element Js.t list option)
  ?(footer : Dom_html.element Js.t list option)
  ?(body : Dom_html.element Js.t list option)
  ?(set : (unit -> unit Lwt.t) ref option)
  (attached_to : Dom_html.element Js.t)
  =
let iter_nodes f container l =
  List.iter
    (fun elt -> f container elt)
    (l)
in
let append_nodes container l =
  iter_nodes Dom.appendChild container l
in
let remove_nodes container =
  iter_nodes
    Dom.removeChild
    container
    (Dom.list_of_nodeList (container##childNodes))
in
object(self)
  val mutable header' = div ~cls:"ojw_popup_header" []
  val mutable footer' = div ~cls:"ojw_popup_footer" []
  val mutable body'   = div ~cls:"ojw_popup_body"   []
  val mutable width' = width

  inherit Ojw_button.alert
        ~button:attached_to
        ~class_:["ojw_popup"]
        ~parent_node:(get_global_bg ())
        ?set
        ()

  method private create_close_button =
    if not close_button
    then None
    else begin
      let b = div ~cls:"ojw_popup_close" [] in
      b##innerHTML <- Js.string "x";
      ignore
        (object
           inherit Ojw_button.button ~button:b ()
           method on_press = (self :> (< close : unit Lwt.t >))#close
         end);
      (Some b)
    end

  method set_header h =
    let butt = match self#create_close_button with
      | None -> []
      | Some b -> [b]
    in
    remove_nodes header';
    let hc = div h in
    hc##style##cssFloat <- Js.string "left";
    append_nodes header' (hc::butt @ [div ~cls:"clear" []])

  method set_footer f =
    remove_nodes footer';
    append_nodes footer' f

  method set_body b =
    remove_nodes body';
    append_nodes body' b

  method show = self#press
  method close = self#unpress

  method update =
    match self#get_alert_box with
      | None -> ()
      | Some abox ->
          let popup_css = Ojw_fun.getComputedStyle abox in
          let open Ojw_unit in
          Ojw_log.log (popup_css##paddingTop);
          Ojw_log.log (popup_css##paddingBottom);
          (abox)##style##width <- pxstring_of_int width';
          let h_inner =
            (int_of_pxstring popup_css##paddingTop)
            + (int_of_pxstring popup_css##paddingBottom)
          in
          let ph = (int_of_pxstring popup_css##height) + (h_inner * 2) in
          let wh = (Dom_html.document##documentElement)##clientHeight in
          Ojw_log.log ("ph:"^(string_of_int ph));
          Ojw_log.log ("wh:"^(string_of_int wh));
          let margin =
            if ph < wh
            then (wh - ph) / 2
            else (20)
          in
          (abox)##style##marginTop <- pxstring_of_int (margin);
          (abox)##style##marginBottom <- pxstring_of_int (margin);

  method on_pre_press =
    if with_background
    then (get_global_bg ())##style##display <- Js.string "block";
    Lwt.return ()

  method on_post_press =
    self#update;
    Lwt.return ()

  method on_post_unpress =
    if with_background
    then (get_global_bg ())##style##display <- Js.string "none";
    Lwt.return ()

  method get_node =
    Lwt.return [header'; body'; footer'];

  method set_width w =
    width' <- w

  method get_width =
    width'

  initializer
  let () = match header with
    | None -> ()
    | Some h -> self#set_header h
  in
  let () = match body with
    | None -> ()
    | Some b -> self#set_body b
  in
  let () = match footer with
    | None -> ()
    | Some f -> self#set_footer f
  in
  Dom.appendChild (Dom_html.document##body :> Dom_html.element Js.t) (get_global_bg ())

end
