// Mike's Experiment for Elevation 3D Print


// E.g. 4x6, 5x7, etc.
// 6x4 = [154, 103]
// 3.5x2.5 = [88.9, 63.5]
nominal_dimensions = [88.9, 63.5];

// Object to print
// "frame", "back"
object_type = "back";


// Output thickness (not including text) (mm)
thickness = 10;
// Depth of the frame in front of the photo. Large value here makes a shadow box.
front_depth = 2;

// Width of a single edge of the frame.
frame_width = 10;

// Where the front of the frame overlaps the photo
inner_photo_margin = 2;

// Tolerance around the outside of the photo on the back of the frame
outer_photo_margin = 1;

// The back plate that holds the photo.
back_thickness = 1;

// END Params.
// Everything below here is generation code.


// Photo positioning
outer_photo_dimensions = [nominal_dimensions.x + outer_photo_margin * 2, nominal_dimensions.y + outer_photo_margin * 2];
inner_photo_dimensions = [nominal_dimensions.x - inner_photo_margin * 2, nominal_dimensions.y - inner_photo_margin * 2];

photo_position = [frame_width, frame_width];



// Combine all the parts
if (object_type == "frame") {
  difference() {
    cube([inner_photo_dimensions.x + 2*frame_width, inner_photo_dimensions.y + 2*frame_width, thickness]);

    translate([photo_position.x, photo_position.y, -0.001]) cube([inner_photo_dimensions.x, inner_photo_dimensions.y, thickness + 0.002]);
    translate([photo_position.x - inner_photo_margin, photo_position.y - inner_photo_margin, -front_depth]) cube([outer_photo_dimensions.x, outer_photo_dimensions.y, thickness]);
    
    // Clip slots
    translate([photo_position.x - inner_photo_margin - 2, photo_position.y + (inner_photo_dimensions.y - 5)/2, thickness - front_depth - 2]) cube([20, 5, 2]);
    translate([photo_position.x + inner_photo_dimensions.x + inner_photo_margin - 20 + 2, photo_position.y + (inner_photo_dimensions.y - 5)/2, thickness - front_depth - 2]) cube([20, 5, 2]);
  }
}


module clip() {
  l1 = 10;
  w = 4;
  h = 6;
  a = 15;
  l_tab = h / cos(a);
  
  cube([l1, w, back_thickness]);
  
  translate([l1, 0, 0]) rotate([0, a, 0]) translate([-back_thickness, 0, 0]) cube([back_thickness, w, l_tab]);
  translate([l1+2*h*tan(a), 0, 0]) rotate([0, -a, 0]) cube([back_thickness, w, l_tab]);
  
  translate([l1+2*h*tan(a), 0, 0]) cube([4, w, back_thickness]);
  
  translate([l1+h*tan(a), 0, h]) difference() {
    rotate([-90, 0, 0]) cylinder(h=w, r=back_thickness, $fn=30);
    translate([0, 0, -10]) cube(20, center=true);
  }
}

if (object_type == "back") {
  len_x = outer_photo_dimensions.x - 0.5;
  len_y = outer_photo_dimensions.y - 0.5;
  
  difference() {
    cube([len_x, len_y, back_thickness]);
    
    translate([-0.001, (len_y - 5)/2, -1]) cube([15, 4+1, back_thickness+2]);
    translate([len_x+0.001 - 15, (len_y - 5)/2, -1]) cube([15, 4+1, back_thickness+2]);
  }
  
  translate([-2, (len_y - 4)/2, 0]) clip();
  translate([len_x + 2, 4 + (len_y - 4)/2, 0]) rotate([0, 0, 180]) clip();
}