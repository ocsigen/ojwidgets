  (*
  module M = Regexp

  let search rex w =
    M.search rex w 0

  let regex_case_insensitive w =
    M.regexp_with_flag w  "i"

  let build_pattern w =
    let w = M.quote w in
    regex_case_insensitive  (("^" ^ w) ^ "|\\s" ^ w)

  let search_case_insensitive w0 w1 =
    if w0 = "" || w0 = w1
    then None
    else
      let pattern = (build_pattern w0) in
      match search pattern w1 with
        | None -> None
        | Some (i,r) -> if i = 0 then Some (i,r) else Some (i+1, r)

  let search_case_accents_i w0 w1 =
    let w0 = Js.to_string (Ojw_fun.removeDiacritics w0) in
    let w1 = Js.to_string (Ojw_fun.removeDiacritics w1) in
    search_case_insensitive w0 w1 (*both arg are caml utf8 string *)

  let searchopt_to_bool w0 w1 =
    match search_case_accents_i w0 w1 with
      | None -> false
      | Some _ -> true

  (* w1 is a completion of w0. ex: is_completed_by "e" "eddy" = yes *)
  (* both arg are utf16 JS string *)
  let is_completed_by w0 w1 =
    if w0 = (Js.string "") || w1 = (Js.string "")
    then false
    else searchopt_to_bool w0 w1
    *)

let nothing r = r
module M = Ojw_internals.Completion_f.Make
    (struct
      type 'a elt = Dom_html.element Js.t
      type element = Dom_html.element

      let to_dom_elt = nothing
      let of_dom_elt = nothing

    end)
    (Ojw_dropdown)

include M
