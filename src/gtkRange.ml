(* $Id$ *)

open Misc
open Gtk
open Tags
open GtkBase

module Progress = struct
  let cast w : progress obj =
    if Object.is_a w "GtkProgress" then Obj.magic w
    else invalid_arg "Gtk.Progress.cast"
  external set_show_text : [> progress] obj -> bool -> unit
      = "ml_gtk_progress_set_show_text"
  external set_text_alignment :
      [> progress] obj -> ?x:float -> ?y:float -> unit
      = "ml_gtk_progress_set_show_text"
  external set_format_string : [> progress] obj -> string -> unit
      = "ml_gtk_progress_set_format_string"
  external set_adjustment : [> progress] obj -> [> adjustment] obj -> unit
      = "ml_gtk_progress_set_adjustment"
  external configure :
      [> progress] obj -> current:float -> min:float -> max:float -> unit
      = "ml_gtk_progress_configure"
  external set_percentage : [> progress] obj -> float -> unit
      = "ml_gtk_progress_set_percentage"
  external set_value : [> progress] obj -> float -> unit
      = "ml_gtk_progress_set_value"
  external get_value : [> progress] obj -> float
      = "ml_gtk_progress_get_value"
  external get_percentage : [> progress] obj -> float
      = "ml_gtk_progress_get_current_percentage"
  external set_activity_mode : [> progress] obj -> bool -> unit
      = "ml_gtk_progress_set_activity_mode"
  external get_current_text : [> progress] obj -> string
      = "ml_gtk_progress_get_current_text"
  external get_adjustment : [> progress] obj -> adjustment obj
      = "ml_gtk_progress_get_adjustment"
end

module ProgressBar = struct
  let cast w : progress_bar obj =
    if Object.is_a w "GtkProgressBar" then Obj.magic w
    else invalid_arg "Gtk.ProgressBar.cast"
  external create : unit -> progress_bar obj = "ml_gtk_progress_bar_new"
  external update : [> progressbar] obj -> percent:float -> unit
      = "ml_gtk_progress_bar_update"
end

module Range = struct
  let cast w : range obj =
    if Object.is_a w "GtkRange" then Obj.magic w
    else invalid_arg "Gtk.Range.cast"
  external coerce : [> range] obj -> range obj = "%identity"
  external get_adjustment : [> range] obj -> adjustment obj
      = "ml_gtk_range_get_adjustment"
  external set_adjustment : [> range] obj -> [> adjustment] obj -> unit
      = "ml_gtk_range_set_adjustment"
  external set_update_policy : [> range] obj -> update_type -> unit
      = "ml_gtk_range_set_update_policy"
  let setter w :cont ?:adjustment ?:update_policy =
    may adjustment fun:(set_adjustment w);
    may update_policy fun:(set_update_policy w);
    cont w
end

module Scale = struct
  let cast w : scale obj =
    if Object.is_a w "GtkScale" then Obj.magic w
    else invalid_arg "Gtk.Scale.cast"
  external hscale_new : [> adjustment] optobj -> scale obj
      = "ml_gtk_hscale_new"
  external vscale_new : [> adjustment] optobj -> scale obj
      = "ml_gtk_vscale_new"
  let create (dir : orientation) ?:adjustment =
    let create = if dir = `HORIZONTAL then hscale_new else vscale_new  in
    create (optboxed adjustment)
  external set_digits : [> scale] obj -> int -> unit
      = "ml_gtk_scale_set_digits"
  external set_draw_value : [> scale] obj -> bool -> unit
      = "ml_gtk_scale_set_draw_value"
  external set_value_pos : [> scale] obj -> position -> unit
      = "ml_gtk_scale_set_value_pos"
  external get_value_width : [> scale] obj -> int
      = "ml_gtk_scale_get_value_width"
  external draw_value : [> scale] obj -> unit
      = "ml_gtk_scale_draw_value"
  let setter w :cont ?:digits ?:draw_value ?:value_pos =
    may digits fun:(set_digits w);
    may draw_value fun:(set_draw_value w);
    may value_pos fun:(set_value_pos w);
    cont w
end

module Scrollbar = struct
  let cast w : scrollbar obj =
    if Object.is_a w "GtkScrollbar" then Obj.magic w
    else invalid_arg "Gtk.Scrollbar.cast"
  external hscrollbar_new : [> adjustment] optobj -> scrollbar obj
      = "ml_gtk_hscrollbar_new"
  external vscrollbar_new : [> adjustment] optobj -> scrollbar obj
      = "ml_gtk_vscrollbar_new"
  let create (dir : orientation) ?:adjustment =
    let create = if dir = `HORIZONTAL then hscrollbar_new else vscrollbar_new
    in create (optboxed adjustment)
end

module Ruler = struct
  let cast w : ruler obj =
    if Object.is_a w "GtkRuler" then Obj.magic w
    else invalid_arg "Gtk.Ruler.cast"
  external hruler_new : unit -> ruler obj = "ml_gtk_hruler_new"
  external vruler_new : unit -> ruler obj = "ml_gtk_vruler_new"
  let create (dir : orientation) =
    if dir = `HORIZONTAL then hruler_new () else vruler_new ()
  external set_metric : [> ruler] obj -> metric_type -> unit
      = "ml_gtk_ruler_set_metric"
  external set_range :
      [> ruler] obj ->
      lower:float -> upper:float -> position:float -> max_size:float -> unit
      = "ml_gtk_ruler_set_range"
  external get_lower : [> ruler] obj -> float = "ml_gtk_ruler_get_lower"
  external get_upper : [> ruler] obj -> float = "ml_gtk_ruler_get_upper"
  external get_position : [> ruler] obj -> float = "ml_gtk_ruler_get_position"
  external get_max_size : [> ruler] obj -> float = "ml_gtk_ruler_get_max_size"
  let setter w :cont ?:metric ?:lower ?:upper ?:position ?:max_size =
    may metric fun:(set_metric w);
    if lower <> None || upper <> None || position <> None || max_size <> None
    then
      set_range w lower:(may_default get_lower w for:lower)
	upper:(may_default get_upper w for:upper)
	position:(may_default get_position w for:position)
	max_size:(may_default get_max_size w for:max_size);
    cont w
end