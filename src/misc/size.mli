val page : Dom_html.element Js.t
module Size :
  sig
    val width_height : (int * int) React.signal
    val width : int React.signal
    val height : int React.signal
    val set_adaptative_width :
      < style : < get : < width : < set : Js.js_string Js.t -> unit; .. >
                                  Js.gen_prop;
                          .. >
                        Js.t;
                  .. >
                Js.gen_prop;
        .. >
      Js.t -> (int -> int) -> unit
    val set_adaptative_height :
      < style : < get : < height : < set : Js.js_string Js.t -> unit; .. >
                                   Js.gen_prop;
                          .. >
                        Js.t;
                  .. >
                Js.gen_prop;
        .. >
      Js.t -> (int -> int) -> unit
    val height_to_bottom :
      < getClientRects : < item : int ->
                                  < top : < get : float Js.t; .. >
                                          Js.gen_prop;
                                    .. >
                                  Js.t Js.Opt.t Js.meth;
                           .. >
                         Js.t Js.meth;
        .. >
      Js.t -> int
  end
val client_top :
  < getBoundingClientRect : < top : < get : float Js.t; .. > Js.gen_prop;
                              .. >
                            Js.t Js.meth;
    .. >
  Js.t -> int
val client_bottom :
  < getBoundingClientRect : < bottom : < get : float Js.t; .. > Js.gen_prop;
                              .. >
                            Js.t Js.meth;
    .. >
  Js.t -> int
val client_left :
  < getBoundingClientRect : < left : < get : float Js.t; .. > Js.gen_prop;
                              .. >
                            Js.t Js.meth;
    .. >
  Js.t -> int
val client_right :
  < getBoundingClientRect : < right : < get : float Js.t; .. > Js.gen_prop;
                              .. >
                            Js.t Js.meth;
    .. >
  Js.t -> int
