/*
Parametric Photo Frame
by Mike Kasberg

A rectangular photo frame that allows you to customize dimensions and depth.
*/

// E.g. 4x6, 5x7, etc.
// 7x5 ....... [177.8, 127]
// 6x4 ....... [154, 103]
// 3.5x2.5 ... [88.9, 63.5]
// 5x7 ....... [172, 177.8]
// 4x6 ....... [103, 154]
// 2.5x3.5 ... [63.5, 88.9]
// Dimensions of the photo to hold (mm)
nominal_dimensions = [154, 103];

// Object to print: "frame", "back"
object_type = "frame";


// Depth of the frame in front of the photo. Large value here makes a shadow box.
front_depth = 2;

// Depth of the frame behind the photo. Should be at least 8 to have room for clips.
back_depth = 20;

// Width of a single edge of the frame.
frame_width = 20;

// Where the front of the frame overlaps the photo. (Probably no adjustment needed.)
inner_photo_margin = 3;

// Tolerance around the outside of the photo on the back of the frame. (Probably no adjustment needed.)
outer_photo_margin = 0.5;

// Thickness of the back plate that holds the photo. (Probably no adjustment needed.)
back_plate_thickness = 1;

// END Params.
// Everything below here is generation code.

thickness = front_depth + back_depth;

// Photo positioning
outer_photo_dimensions = [nominal_dimensions.x + outer_photo_margin * 2, nominal_dimensions.y + outer_photo_margin * 2];
inner_photo_dimensions = [nominal_dimensions.x - inner_photo_margin * 2, nominal_dimensions.y - inner_photo_margin * 2];

photo_position = [frame_width, frame_width];

/**
 * Generates a 3D "hanger hole" for hanging on a nail or hook.
 * Note that this module creates a 3D volume that can be removed from another
 * (e.g. with difference).
 */
module hanger_hole() {
  translate([0, -8, -0.01]) {
    translate([0, 0, 1]) {
      hull() {
        cylinder(h=2, r = 3, $fn=30);
        translate([0, 5, 0]) cylinder(h=2, r=3, $fn=30);
      }
    }
    hull() {
      cylinder(h=1.001, r=1.5, $fn=20);
      translate([0, 5, 0]) cylinder(h=1.001, r=1.5, $fn=20);
    }
    cylinder(h=1.001, r=3, $fn=30);
  }
}

// Combine all the parts
if (object_type == "frame") {
  difference() {
    cube([inner_photo_dimensions.x + 2*frame_width, inner_photo_dimensions.y + 2*frame_width, thickness]);

    // Innermost cutout for viewing photo
    translate([photo_position.x, photo_position.y, -0.001])
      cube([inner_photo_dimensions.x, inner_photo_dimensions.y, thickness + 0.002]);
    // Back photo slot
    translate([photo_position.x - inner_photo_margin - outer_photo_margin, photo_position.y - inner_photo_margin - outer_photo_margin, -front_depth])
      cube([outer_photo_dimensions.x, outer_photo_dimensions.y, thickness]);
    
    // Clip slots
    translate([
      photo_position.x - inner_photo_margin - outer_photo_margin - 3,
      photo_position.y + (inner_photo_dimensions.y - 5)/2,
      thickness - front_depth - 2
    ]) cube([20, 5, 2]);
    translate([
      photo_position.x + inner_photo_dimensions.x + inner_photo_margin + outer_photo_margin - 20 + 3,
      photo_position.y + (inner_photo_dimensions.y - 5)/2,
      thickness - front_depth - 2
    ]) cube([20, 5, 2]);

    // Hanger hole
    translate([inner_photo_dimensions.x / 2 + frame_width, inner_photo_dimensions.y + 2*frame_width - 1, 0]) hanger_hole();
  }
}


module clip() {
  l1 = 10;
  w = 4;
  h = min(6, back_depth - back_plate_thickness-2);
  a = 15;
  l_tab = h / cos(a);
  
  cube([l1, w, back_plate_thickness]);
  
  translate([l1, 0, 0]) rotate([0, a, 0]) translate([-back_plate_thickness, 0, 0]) cube([back_plate_thickness, w, l_tab]);
  translate([l1+2*h*tan(a), 0, 0]) rotate([0, -a, 0]) cube([back_plate_thickness, w, l_tab]);
  
  translate([l1+2*h*tan(a), 0, 0]) cube([4, w, back_plate_thickness]);
  
  translate([l1+h*tan(a), 0, h]) difference() {
    rotate([-90, 0, 0]) cylinder(h=w, r=back_plate_thickness, $fn=30);
    translate([0, 0, -10]) cube(20, center=true);
  }
}

if (object_type == "back") {
  len_x = outer_photo_dimensions.x - 0.5;
  len_y = outer_photo_dimensions.y - 0.5;
  
  difference() {
    cube([len_x, len_y, back_plate_thickness]);
    
    translate([-0.001, (len_y - 5)/2, -1]) cube([15, 4+1, back_plate_thickness+2]);
    translate([len_x+0.001 - 15, (len_y - 5)/2, -1]) cube([15, 4+1, back_plate_thickness+2]);
  }
  
  translate([-1.5, (len_y - 4)/2, 0]) clip();
  translate([len_x + 1.5, 4 + (len_y - 4)/2, 0]) rotate([0, 0, 180]) clip();
}
