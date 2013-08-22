(* Copyright Université Paris Diderot.

   Author : Arnaud Parant
*)

module StorageBase =
struct

  type t = Dom_html.storage Js.t
  type 'a key = Js.js_string Js.t * 'a Deriving_Json.t

  let get_opt_storage opt_storage string_failure =
    Js.Optdef.case opt_storage
      (fun () -> failwith string_failure)
      (fun v -> v)

  let length storage =
    storage##length

  let create_key key_name json_type =
    Js.string key_name, json_type

  let opt_get opt_value func =
    Js.Opt.case opt_value
      (fun () -> None)
      (fun v -> Some (func v))

  let get_name_key storage id =
    let opt_value = storage##key(id) in
    opt_get opt_value (fun v -> Js.to_string v)

  let get_item storage (js_key_name, json_type) =
    let opt_value = storage##getItem(js_key_name) in
    opt_get opt_value (fun v ->
      Deriving_Json.from_string json_type (Js.to_string v))

  let get_noopt_item storage key default =
    let opt_value = get_item storage key in
    match opt_value with
      | Some v  -> v
      | None    -> default

  let set_item storage (js_key_name, json_type) value =
    let item = Js.string (Deriving_Json.to_string json_type value) in
    storage##setItem(js_key_name, item)

  let remove_item storage (js_key_name, json_type) =
    storage##removeItem(js_key_name)

  let clear storage =
    storage##clear()

end

module type JSSTORAGE =
  sig

    type t
    type 'a key

    (** If storage does not existe,
        It launch failwith "Storage is not available" *)
    val get : unit -> t

    val length : t -> int

    (** [create_key name json_type] *)
    val create_key : string -> 'a Deriving_Json.t -> 'a key

    (** [get_name_key storage index] *)
    val get_name_key : t -> int -> string option

    val get_item : t -> 'a key -> 'a option

    (** [get_noopt_item storage key json_type default_value] *)
    val get_noopt_item : t -> 'a key -> 'a -> 'a

    val set_item : t -> 'a key -> 'a -> unit

    val remove_item : t -> 'a key -> unit

    val clear : t -> unit

  end

let error_string = "Storage is not available"

module LocalStorage : JSSTORAGE =
  struct

    include StorageBase

    let get () =
      get_opt_storage
        Dom_html.window##localStorage
        error_string

  end

module SessionStorage : JSSTORAGE =
  struct

    include StorageBase

    let get () =
      get_opt_storage
        Dom_html.window##sessionStorage
        error_string

  end
