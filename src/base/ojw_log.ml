
let alert s = Dom_html.window##alert(Js.string s)

let alert_int s = Dom_html.window##alert(Js.string (string_of_int s))

let log s = Firebug.console##log(Js.string s)

let log_int s = Firebug.console##log(Js.string (string_of_int s))
