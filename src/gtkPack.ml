(* $Id$ *)

open Misc
open Gtk
open Tags
open GtkBase

module Box = struct
  let cast w : box obj =
    if Object.is_a w "GtkBox" then Obj.magic w
    else invalid_arg "Gtk.Box.cast"
  external coerce : [> box] obj -> box obj = "%identity"
  external pack_start :
      [> box] obj -> [> widget] obj ->
      expand:bool -> fill:bool -> padding:int -> unit
      = "ml_gtk_box_pack_start"
  external pack_end :
      [> box] obj -> [> widget] obj ->
      expand:bool -> fill:bool -> padding:int -> unit
      = "ml_gtk_box_pack_end"
  let pack box child ?from:dir [< (`START : pack_type) >]
      ?:expand [< true >] ?:fill [< true >] ?:padding [< 0 >] =
    (match dir with `START -> pack_start | `END -> pack_end)
      box child :expand :fill :padding
  external set_homogeneous : [> box] obj -> bool -> unit
      = "ml_gtk_box_set_homogeneous"
  external set_spacing : [> box] obj -> int -> unit
      = "ml_gtk_box_set_spacing"
  let setter w :cont ?:homogeneous ?:spacing =
    may homogeneous fun:(set_homogeneous w);
    may spacing fun:(set_spacing w);
    cont w
  type packing =
      { expand: bool; fill: bool; padding: int; pack_type: pack_type }
  external query_child_packing : [> box] obj -> [> widget] obj -> packing
      = "ml_gtk_box_query_child_packing"
  external set_child_packing :
      [> box] obj -> [> widget] obj ->
      ?expand:bool -> ?fill:bool -> ?padding:int -> ?from:pack_type -> unit
      = "ml_gtk_box_set_child_packing_bc" "ml_gtk_box_set_child_packing"
  external hbox_new : homogeneous:bool -> spacing:int -> box obj
      = "ml_gtk_hbox_new"
  external vbox_new : homogeneous:bool -> spacing:int -> box obj
      = "ml_gtk_vbox_new"
  let create (dir : orientation) ?:homogeneous [< false >] ?:spacing [< 0 >] =
    (match dir with `HORIZONTAL -> hbox_new | `VERTICAL -> vbox_new)
      :homogeneous :spacing
end

module BBox = struct
  (* Omitted defaults setting *)
  let cast w : button_box obj =
    if Object.is_a w "GtkBBox" then Obj.magic w
    else invalid_arg "Gtk.BBox.cast"
  external coerce : [> bbox] obj -> button_box obj = "%identity"
  type bbox_style = [ DEFAULT_STYLE SPREAD EDGE START END ]
  external get_spacing : [> bbox] obj -> int = "ml_gtk_button_box_get_spacing"
  external get_child_width : [> bbox] obj -> int
      = "ml_gtk_button_box_get_child_min_width"
  external get_child_height : [> bbox] obj -> int
      = "ml_gtk_button_box_get_child_min_height"
  external get_child_ipadx : [> bbox] obj -> int
      = "ml_gtk_button_box_get_child_ipad_x"
  external get_child_ipady : [> bbox] obj -> int
      = "ml_gtk_button_box_get_child_ipad_y"
  external get_layout : [> bbox] obj -> bbox_style
      = "ml_gtk_button_box_get_layout_style"
  external set_spacing : [> bbox] obj -> int -> unit
      = "ml_gtk_button_box_set_spacing"
  external set_child_size : [> bbox] obj -> width:int -> height:int -> unit
      = "ml_gtk_button_box_set_child_size"
  external set_child_ipadding : [> bbox] obj -> x:int -> y:int -> unit
      = "ml_gtk_button_box_set_child_ipadding"
  external set_layout : [> bbox] obj -> bbox_style -> unit
      = "ml_gtk_button_box_set_layout"
  let setter w :cont ?:spacing ?:child_width ?:child_height ?:child_ipadx
      ?:child_ipady ?:layout =
    may spacing fun:(set_spacing w);
    if child_width <> None || child_height <> None then
      set_child_size w width:(may_default get_child_width w for:child_width)
	height:(may_default get_child_height w for:child_height);
    if child_ipadx <> None || child_ipady <> None then
      set_child_ipadding w
	x:(may_default get_child_ipadx w for:child_ipadx)
	y:(may_default get_child_ipady w for:child_ipady);
    may layout fun:(set_layout w);
    cont w
  external set_child_size_default : width:int -> height:int -> unit
      = "ml_gtk_button_box_set_child_size_default"
  external set_child_ipadding_default : x:int -> y:int -> unit
      = "ml_gtk_button_box_set_child_ipadding_default"
  external create_hbbox : unit -> button_box obj = "ml_gtk_hbutton_box_new"
  external create_vbbox : unit -> button_box obj = "ml_gtk_vbutton_box_new"
  let create (dir : orientation) =
    if dir = `HORIZONTAL then create_hbbox () else create_vbbox ()
end

module Fixed = struct
  let cast w : fixed obj =
    if Object.is_a w "GtkFixed" then Obj.magic w
    else invalid_arg "Gtk.Fixed.cast"
  external create : unit -> fixed obj = "ml_gtk_fixed_new"
  external put : [> fixed] obj -> [> widget] obj -> x:int -> y:int -> unit
      = "ml_gtk_fixed_put"
  external move : [> fixed] obj -> [> widget] obj -> x:int -> y:int -> unit
      = "ml_gtk_fixed_move"
end

module Packer = struct
  let cast w : packer obj =
    if Object.is_a w "GtkPacker" then Obj.magic w
    else invalid_arg "Gtk.Packer.cast"
  external create : unit -> packer obj = "ml_gtk_packer_new"
  external add :
      [> packer] obj -> [> widget] obj ->
      ?side:side_type -> ?anchor:anchor_type ->
      ?options:packer_options list ->
      ?border_width:int -> ?pad_x:int -> ?pad_y:int ->
      ?i_pad_x:int -> ?i_pad_y:int -> unit
      = "ml_gtk_packer_add_bc" "ml_gtk_packer_add"
  external add_defaults :
      [> packer] obj -> [> widget] obj ->
      ?side:side_type -> ?anchor:anchor_type ->
      ?options:packer_options list -> unit
      = "ml_gtk_packer_add_defaults"
  external set_child_packing :
      [> packer] obj -> [> widget] obj ->
      ?side:side_type -> ?anchor:anchor_type ->
      ?options:packer_options list ->
      ?border_width:int -> ?pad_x:int -> ?pad_y:int ->
      ?i_pad_x:int -> ?i_pad_y:int -> unit
      = "ml_gtk_packer_set_child_packing_bc" "ml_gtk_packer_set_child_packing"
  external reorder_child : [> packer] obj -> [> widget] obj -> pos:int -> unit
      = "ml_gtk_packer_reorder_child"
  external set_spacing : [> packer] obj -> int -> unit
      = "ml_gtk_packer_set_spacing"
  external set_defaults :
      [> packer] obj -> 
      ?side:side_type -> ?anchor:anchor_type ->
      ?options:packer_options list ->
      ?border_width:int -> ?pad_x:int -> ?pad_y:int ->
      ?i_pad_x:int -> ?i_pad_y:int -> unit
      = "ml_gtk_packer_set_defaults_bc" "ml_gtk_packer_set_defaults"
end

module Paned = struct
  let cast w : paned obj =
    if Object.is_a w "GtkPaned" then Obj.magic w
    else invalid_arg "Gtk.Paned.cast"
  external add1 : [> paned] obj -> [> widget] obj -> unit
      = "ml_gtk_paned_add1"
  external add2 : [> paned] obj -> [> widget] obj -> unit
      = "ml_gtk_paned_add2"
  let add w ?:fst ?:snd =
    may fun:(add1 w) fst;
    may fun:(add2 w) snd
  external set_handle_size : [> paned] obj -> int -> unit
      = "ml_gtk_paned_set_handle_size"
  external set_gutter_size : [> paned] obj -> int -> unit
      = "ml_gtk_paned_set_gutter_size"
  let setter w :cont ?:handle_size ?:gutter_size =
    may fun:(set_handle_size w) handle_size;
    may fun:(set_gutter_size w) gutter_size;
    cont w
  external hpaned_new : unit -> paned obj = "ml_gtk_hpaned_new"
  external vpaned_new : unit -> paned obj = "ml_gtk_vpaned_new"
  let create (dir : orientation) =
    if dir = `HORIZONTAL then hpaned_new () else vpaned_new ()
end

module Table = struct
  let cast w : table obj =
    if Object.is_a w "GtkTable" then Obj.magic w
    else invalid_arg "Gtk.Table.cast"
  external create : int -> int -> homogeneous:bool -> table obj
      = "ml_gtk_table_new"
  let create rows:r columns:c ?:homogeneous [< false >] =
    create r c :homogeneous
  external attach :
      [> table] obj -> [> widget] obj -> left:int -> right:int ->
      top:int -> bottom:int -> xoptions:attach_options list ->
      yoptions:attach_options list -> xpadding:int -> ypadding:int -> unit
      = "ml_gtk_table_attach_bc" "ml_gtk_table_attach"
  let has_x : expand_type -> bool =
    function `X|`BOTH -> true | `Y|`NONE -> false
  let has_y : expand_type -> bool =
    function `Y|`BOTH -> true | `X|`NONE -> false
  let attach t w :left :top ?:right [< left+1 >] ?:bottom [< top+1 >]
      ?:expand [< `BOTH >] ?:fill [< `BOTH >]
      ?:shrink [< `NONE >] ?:xpadding [< 0 >] ?:ypadding [< 0 >] =
    let xoptions = if has_x shrink then [`SHRINK] else [] in
    let xoptions = if has_x fill then `FILL::xoptions else xoptions in
    let xoptions = if has_x expand then `EXPAND::xoptions else xoptions in
    let yoptions = if has_y shrink then [`SHRINK] else [] in
    let yoptions = if has_y fill then `FILL::yoptions else yoptions in
    let yoptions = if has_y expand then `EXPAND::yoptions else yoptions in
    attach t w :left :top :right :bottom :xoptions :yoptions
      :xpadding :ypadding
  external set_row_spacing : [> table] obj -> int -> int -> unit
      = "ml_gtk_table_set_row_spacing"
  external set_col_spacing : [> table] obj -> int -> int -> unit
      = "ml_gtk_table_set_col_spacing"
  external set_row_spacings : [> table] obj -> int -> unit
      = "ml_gtk_table_set_row_spacings"
  external set_col_spacings : [> table] obj -> int -> unit
      = "ml_gtk_table_set_col_spacings"
  external set_homogeneous : [> table] obj -> bool -> unit
      = "ml_gtk_table_set_homogeneous"
  let setter w :cont ?:row_spacings ?:col_spacings ?:homogeneous =
    may row_spacings fun:(set_row_spacings w);
    may col_spacings fun:(set_col_spacings w);
    may homogeneous fun:(set_homogeneous w);
    cont w
end