(* $Id$ *)

(* Embedding xpm data into an ML file *)

let openfile = [|
(* width height num_colors chars_per_pixel *)
"    20    19       5            1";
(* colors *)
". c None";
"# c #000000";
"i c #ffffff";
"s c #7f7f00";
"y c #ffff00";
(* pixels *)
"....................";
"....................";
"....................";
"...........###......";
"..........#...#.#...";
"...............##...";
"...###........###...";
"..#yiy#######.......";
"..#iyiyiyiyi#.......";
"..#yiyiyiyiy#.......";
"..#iyiy###########..";
"..#yiy#sssssssss#...";
"..#iy#sssssssss#....";
"..#y#sssssssss#.....";
"..##sssssssss#......";
"..###########.......";
"....................";
"....................";
"...................." |]

open GMain

let main () =
  let w = new GWindow.window border_width:2 in
  w#misc#realize ();
  let hbox = new GPack.box `HORIZONTAL spacing:10 packing:w#add in
  let pm =
    new GdkObj.pixmap_from_xpm_d data:openfile window:w#misc#window in
  new GPix.pixmap pm packing:hbox#add;
  new GMisc.label text:"Embedded xpm" packing:hbox#add;
  w#show ();
  w#connect#destroy callback:Main.quit;
  Main.main ()

let () = main ()