(* $Id$ *)

open Misc
open Gtk

module Arg = struct
  type t
  external shift : t -> pos:int -> t = "ml_gtk_arg_shift"
  external get_type : t -> gtk_type = "ml_gtk_arg_get_type"
  (* Safely get an argument *)
  external get_char : t -> char = "ml_gtk_arg_get_char"
  external get_bool : t -> bool = "ml_gtk_arg_get_bool"
  external get_int : t -> int = "ml_gtk_arg_get_int"
  external get_float : t -> float = "ml_gtk_arg_get_float"
  (* These 3 may raise [Null_pointer] *)
  external get_string : t -> string = "ml_gtk_arg_get_string"
  external get_pointer : t -> pointer = "ml_gtk_arg_get_pointer"
  external get_object : t -> unit obj = "ml_gtk_arg_get_object"
  (* Safely set a result
     Beware: this is not the opposite of get, arguments and results
     are two different ways to use GtkArg. *)
  external set_char : t -> char -> unit = "ml_gtk_arg_set_char"
  external set_bool : t -> bool -> unit = "ml_gtk_arg_set_bool"
  external set_int : t -> int -> unit = "ml_gtk_arg_set_int"
  external set_float : t -> float -> unit = "ml_gtk_arg_set_float"
  external set_string : t -> string -> unit = "ml_gtk_arg_set_string"
  external set_pointer : t -> pointer -> unit = "ml_gtk_arg_set_pointer"
  external set_object : t -> 'a obj -> unit = "ml_gtk_arg_set_object"
end

open Arg
type raw_obj
type t = { referent: raw_obj; nargs: int; args: Arg.t }
let nth arg :pos =
  if pos < 0 || pos >= arg.nargs then invalid_arg "GtkArg.Vect.nth";
  shift arg.args :pos
let result arg =
  if arg.nargs < 0 then invalid_arg "GtkArg.Vect.result";
  shift arg.args pos:arg.nargs
external wrap_object : raw_obj -> unit obj = "Val_GtkObject"
let referent arg =
  if arg.referent == Obj.magic (-1) then invalid_arg "GtkArg.Vect.referent";
  wrap_object arg.referent
let get_result_type arg = get_type (result arg)
let get_type arg :pos = get_type (nth arg :pos)
let get_char arg :pos = get_char (nth arg :pos)
let get_bool arg :pos = get_bool (nth arg :pos)
let get_int arg :pos = get_int (nth arg :pos)
let get_float arg :pos = get_float (nth arg :pos)
let get_string arg :pos = get_string (nth arg :pos)
let get_pointer arg :pos = get_pointer (nth arg :pos)
let get_object arg :pos = get_object (nth arg :pos)
let set_result_char arg = set_char (result arg)
let set_result_bool arg = set_bool (result arg)
let set_result_int arg = set_int (result arg)
let set_result_float arg = set_float (result arg)
let set_result_string arg = set_string (result arg)
let set_result_pointer arg = set_pointer (result arg)
let set_result_object arg = set_object (result arg)