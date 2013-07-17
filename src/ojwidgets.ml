(* Copyright Université Paris Diderot. *)

module Oscrollbar = Oscrollbar

module Oslider = Oslider

module Button = struct
  include Button
  include Button_alert
  include Button_show_hide
  include Button_show_hide_focus
end

(* Misc modules *)
module Log = Log

module Size = Size

module F = struct
  module Button_f = Button_f
  module Button_alert_f = Button_alert_f
  module Button_show_hide_f = Button_show_hide_f
  module Button_show_hide_focus_f = Button_show_hide_focus_f
end
