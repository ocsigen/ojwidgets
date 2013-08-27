(*** Enable / Disable ***)

let disable_zoom () =
  Ojw_event_tools.disable_event Dom_html.Event.touchmove Dom_html.document

let hide_navigation_bar () =
  Dom_html.window##scroll(0,1)
