
module type T = sig
  (** A completion widget to complete on string value. *)

  module D : Ojw_dom_sigs.T
  module Dropdown : Ojw_dropdown_sigs.T
  module Tr : Ojw_traversable_sigs.T

  (** A [completion] widget is [dropdown] widget. The list of the
    * possible values are displayed using a [dropdown]. *)
  class type completion = object
    inherit Dropdown.dropdown

    (** You can retrieve the value of the [completion] widget or even
      * change it (you need to [refresh] explicitly the widget). *)
    method value : Js.js_string Js.t Js.prop

    (** Clear the list of the possible values. The content will be
      * automatically refresh during the next action. *)
    method clear : unit Js.meth

    (** Explicitly confirm with the current value of the input. *)
    method confirm : unit Lwt.t Js.meth

    (** Explicitly refresh the content of the widget (using the given
     * function [refresh] on the construction of the widget). *)
    method refresh : unit Lwt.t Js.meth
  end

  (** Provides behaviours of a completion widget.
    *
    * The main purpose of this widget is to complete on string value.
    * [completion] uses [dropdown] to display matched values. Each item of the
    * [dropdown] {b MUST HAVE} an attribute {b data-value}. The value of this
    * attribute will be used during comparaison with the input value.
    *
    * [refresh limit pattern] must return the list of the different values.
    * The [pattern] correspond to the current input value, and [limit] is the
    * number of items which will be displayed by the widgets.
    *
    * If you don't want to do the comparaison with the value by yourself, you
    * can use [auto_match] which will filter the list of elements returned by
    * [refresh] function. Element which doesn't match the input value, will be
    * ignored and won't be displayed with the [dropdown].
    *
    * [accents] indicates if the widget has to take care of accents in the
    * {b data-value} attribute and input value.  [sensitive] indicates the case
    * has to be insensitive or not.
    *
    * If you want to begin the completion from the start of input value, you
    * can set [from_start] to [true]. Otherwise, it will try to match the value
    * anywhere in the {data-value} string.
    *
    * [force_refresh] will automatically force the call to the [refresh]
    * function on each actions of the widget. If this option is enabled, the
    * rendering could blink.
    *
    * [clear_input_on_confirm] will clear the input when method [confirm] is
    * called.
    *
    * Because [completion] is a [dropdown], and a [dropdown] is composed by
    * [traversable] widget, you can navigate through matched values using
    * arrow keys. You can also iterate through them using tab key, if the
    * option [move_with_tab] is set to [true]
    *
    * If [adaptive] is enabled, so the input value will be automatically set
    * to the {b data-value} of current active matched element (when navigating
    * using arrow keys).
    *
    * The function [on_confirm] is called each time the input value is
    * confirmed (using [confirm] method or using enter key).
    *
    * The widget need an {b input} element as first parameter. The second
    * parameter is the container on which the matched values will be
    * automatically inserted, it must be a {b ul} element.
    *
    * *)
  val completion__ :
     refresh : (int -> string -> Dropdown.Traversable.Content.element Dropdown.Traversable.Content.elt list Lwt.t)
  -> ?limit : int
  -> ?accents : bool
  -> ?from_start : bool
  -> ?force_refresh : bool
  -> ?sensitive : bool
  -> ?adaptive : bool
  -> ?auto_match : bool
  -> ?clear_input_on_confirm : bool
  -> ?move_with_tab : bool
  -> ?on_confirm : (string -> unit Lwt.t)
  -> D.element D.elt
  -> Dropdown.Traversable.D.element Dropdown.Traversable.D.elt
  -> (Dropdown.D.element Dropdown.D.elt *
      Dropdown.Traversable.D.element Dropdown.Traversable.D.elt)
end
