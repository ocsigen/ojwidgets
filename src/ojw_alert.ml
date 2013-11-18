open Dom
open Dom_html

type parent = element Js.t
type container = element Js.t
type container_content = element Js.t

let nothing r = r
include Ojw_alert_f.Make(struct
  type parent' = parent
  type container' = container
  type container_content' = container_content

  let to_container = nothing
  let to_parent = nothing

  let of_container = nothing

  let default_parent () = document##body

  let default_container cnt =
    let container = createDiv document in
    List.iter (appendChild container) cnt;
    container
end)
