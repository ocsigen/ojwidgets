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
  val mutable popup'  = div ~cls:"ojw_popup"        []
  val mutable width' = width

  inherit Ojw_button.alert
        ~button:attached_to
        ~parent_node:(Dom_html.document##body)
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

  method to_html =
    popup'

  method show = self#press
  method close = self#unpress

  method update =
    let popup_css = Ojw_fun.getComputedStyle self#to_html in
    let open Ojw_unit in
    (self#to_html)##style##width <- pxstring_of_int width';
    let w_inner =
      (int_of_pxstring popup_css##paddingLeft)
      + (int_of_pxstring popup_css##paddingRight)
      + (int_of_pxstring popup_css##borderLeft)
      + (int_of_pxstring popup_css##borderRight)
    in
    let h_inner =
      (int_of_pxstring popup_css##paddingTop)
      + (int_of_pxstring popup_css##paddingBottom)
      + (int_of_pxstring popup_css##borderTop)
      + (int_of_pxstring popup_css##borderBottom)
    in
    let pw = ((int_of_pxstring popup_css##width) + (w_inner * 2)) / 2 in
    let ph = ((int_of_pxstring popup_css##height) + (h_inner * 2)) / 2 in
    (self#to_html)##style##marginLeft <- pxstring_of_int (-pw);
    (self#to_html)##style##marginTop <- pxstring_of_int (-ph);


  method on_pre_press =
    if with_background
    then (get_global_bg ())##style##display <- Js.string "block";
    Lwt.return ()

  method on_post_press =
    (self#to_html)##style##display <- Js.string "block";
    self#update;
    Lwt.return ()

  method on_post_unpress =
    if with_background
    then (get_global_bg ())##style##display <- Js.string "none";
    Lwt.return ()

  method get_node =
    Lwt.return [self#to_html]

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
  popup' <- div ~cls:"ojw_popup" [header'; body'; footer'];
  Dom.appendChild (Dom_html.document##body :> Dom_html.element Js.t) (get_global_bg ())

end
