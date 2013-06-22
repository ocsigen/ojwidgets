(* Copyright Université Paris Diderot.
   @author : Gabriel Radanne
*)


let make_draggable 
    ?(label=Js.string "text") 
    dom_ref 
    ( elem, info ) = 
  let open Lwt_js_events in
  let data = Js.string "" in

  let ondragstart ev _ =
    dom_ref := Some (elem,info) ;
    ev##dataTransfer##setData(label, data) ;
    Lwt.return () in

  let ondragend ev _ = 
    if ev##dataTransfer##dropEffect = Js.string "none" then
      dom_ref := None ;
    Lwt.return () in

  (* The type annotation is necessary because of a limitation in optional arguments *)
  List.iter 
    (fun (ev,f) -> Lwt.async (fun () -> (ev : ?use_capture:'a -> 'b)  elem f))
    [ dragstarts, ondragstart ;
      dragends, ondragend ]


let make_dropzone dom_ref 
    ?(label=Js.string "text") ?drop_callback ?over_class 
    ( dropzone, f, info ) = 
  let open Lwt_js_events in

  let ondragover  ev _   =
    if Js.to_bool ev##dataTransfer##types##contains(label) then 
      begin
	preventDefault ev ;
	Option.iter (fun c -> dropzone##classList##add(c)) over_class ;
	ev##dataTransfer##dropEffect <- Js.string "move"
      end ;
    Lwt.return () 
  in

  let ondrop ev _  =
    preventDefault ev ;
    Option.iter (fun c -> dropzone##classList##add(c)) over_class ;
    let droped_elem = !dom_ref in 
    dom_ref := None ;
    Option.iter_lwt
      (fun (elem, draginfo) ->
	 lwt () = Option.iter_lwt (fun f -> f info draginfo) drop_callback in
	 let () = Js.Opt.iter (elem##parentNode) (fun x -> Dom.removeChild x elem) in
	 Lwt.return (f elem draginfo)
      )
      droped_elem in

  let ondragleave ev _ = 
    preventDefault ev ;
    Option.iter (fun c -> dropzone##classList##add(c)) over_class ;
    Lwt.return () in

  (* The type annotation is necessary because of a limitation in optional arguments *)
  List.iter 
    (fun (ev,f) -> Lwt.async (fun () -> (ev : ?use_capture:'a -> 'b) dropzone f))
    [ dragovers, ondragover ;
      drops, ondrop ;
      dragleaves, ondragleave ;
    ]

let init
    ?drop_callback ?label ?over_class 
    draggables dropzones = 
  Random.self_init () ; 
  let label = Js.string (
      match label with
	| Some x -> x 
	| None ->  Random.self_init () ; string_of_int (Random.bits ())
    ) in
  let dom_ref = ref None in
  let over_class = Option.map Js.string over_class in

  List.iter 
    (make_draggable ~label dom_ref) 
    draggables ;
  
  List.iter 
    (make_dropzone ~label dom_ref ?drop_callback ?over_class) 
    dropzones ;

  ()
