(* Copyright Université Paris Diderot

Author : Vincent Balat
   Christophe Lecointe
*)

module In_dom_element_m = struct
  type element_t = Dom_html.element Js.t

  let to_element element = element
end

include Scrollbar_f.Make(In_dom_element_m)
