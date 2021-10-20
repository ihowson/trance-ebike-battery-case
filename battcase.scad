// all dimensions are in millimetres

PART = "none";
DISPLAY = 1;

// material thickness
thick = 4.5;

// inside width of the box -- 65mm for cells plus a bit for welding, padding and cabling
// with 4.5mm polycarbonate, this gives a total width of 89mm
width = 80;

// original measurements
// edge_path = [[0,0],[405,0],[414,-84],[334,-124],[309, -166],[0,-25]];
edge_path = [
    [0,0], // top left
    [406,0], // top right
    [415,-85], // rightmost, on top of shock
    [309, -169], // bottom
    [0,-25], // left edge underneath
];

top_start = edge_path[0];
top_end = edge_path[1];
top_length = norm(top_end - top_start);

rear_start = edge_path[1];
rear_end = edge_path[2]; // teehee
rear_length = norm(rear_end - rear_start);
rear_angle = atan2(rear_end[0] - rear_start[0], rear_end[1] - rear_start[1]);

shock_start = edge_path[2];
shock_end = edge_path[3];
shock_length = norm(shock_end - shock_start);
shock_angle = atan2(shock_end[0] - shock_start[0], shock_end[1] - shock_start[1]);

bottom_start = edge_path[3];
bottom_end = edge_path[4];
bottom_length = norm(bottom_end - bottom_start);
bottom_angle = atan2(bottom_end[0] - bottom_start[0], bottom_end[1] - bottom_start[1]);

cap_start = edge_path[4];
cap_end = edge_path[0];
cap_length = norm(cap_end - cap_start);
cap_angle = atan2(cap_end[0] - cap_start[0], cap_end[1] - cap_start[1]);

chop_length = thick + .5; // TODO: customize this for each join. this is eyeballed.

// Throughout, I have the strap width set to correspond to the diameter of the
// frame tubes. This isn't actually necessary. They can be much narrower so
// there is less loose strap flapping around. I've chosen to leave it open like
// this to give some convenient straps to route cables through.
module strap_hole_pair(delta) {
    centre_line = width / 2;

    translate([0, centre_line - delta/2, 0])
        square([25, 5], center=true);
    translate([0, centre_line + delta/2, 0])
        square([25, 5], center=true);
}

module xt60_panel() {
    // TODO: revise this to put the socket flange on the outside of the case,
    // since the material is too thick now
    // NOTE: not doing this as we don't have space. it's going to overlap a bit.
    // NOTE: you'll probably need to file out the corners; they won't be sharp enough to fit.
    square([15.7, 8.3], center=true);  // nominally 15.5x8.1

    // NOTE: no holes. you will need to drill these manually.
    // translate([-10.25, 0, 0]) circle(d=3.2, $fn=32);
    // translate([10.25, 0, 0]) circle(d=3.2, $fn=32);
}

module switch_hole() {
    square([13.7, 8.8], center=true);  // eyeballed it
}

module top_plate() {
    strap_delta = 38;
    difference() {
        // rounding(r=3, $fn=32) square([top_length, width]);
        square([top_length, width]);

        translate([40, 0, 0]) strap_hole_pair(strap_delta);
        translate([150, 0, 0]) strap_hole_pair(strap_delta);
        translate([260, 0, 0]) strap_hole_pair(strap_delta);
        translate([top_length-57, 0, 0]) strap_hole_pair(strap_delta); // special placement to fit inside 'handle'      

        // make a notch for the xt60 nut
        translate([0, width-thick - 8.3/2, 0]) square([4, 9]);
    }
}

module rear_plate() {
    strap_delta = 35;

    difference() {
        // rounding(r=3, $fn=32) square([rear_length, width]);
        square([rear_length, width]);

        // chop off the top meterial_thickness+2mm to make space for the top plate
        square([chop_length, width], center=false);

        translate([rear_length/2, 0, 0]) strap_hole_pair(strap_delta);
    }
}

module shock_plate() {    
    difference() {
        square([shock_length, width]);
    
        // chop off the top thick+2mm to make space for the rear plate
        // bottom edge
        square([chop_length, width], center=false);
        // top edge
        translate([shock_length-chop_length, 0, 0]) square([chop_length, width], center=false);

        // chop off the bottom thick+2mm to make space for the bottom plate
        translate([shock_length-chop_length, 0, 0]) square([chop_length, width], center=false);
    
        // discharge cable hole
        translate([shock_length-20, width-6, 0]) square([15, 6]);
    }
}

module zip_tie_hole() {
    square([5, 5]);
}

module bottom_plate() {
    strap_delta = 49;

    difference() {
        // rounding(r=3, $fn=32) square([bottom_length, width]);
        square([bottom_length, width]);

        translate([bottom_length*(1/7), 0, 0]) strap_hole_pair(strap_delta);
        translate([bottom_length*0.5, 0, 0]) strap_hole_pair(strap_delta);
        translate([bottom_length*(6/7), 0, 0]) strap_hole_pair(strap_delta);

        // make a notch for the xt60 nut
        translate([bottom_length-thick+1, width-thick - 8.3/2, 0]) square([4, 9]);

        translate([8, width-8, 0]) zip_tie_hole();
    }
}

// one endcap
module cap_want() {
    difference() {
        square([cap_length, width + 2 * thick]);
        translate([12.5, width+0.1, 0]) xt60_panel();
        translate([12.5, thick+5, 0]) switch_hole();
    }
}

module cap() {
    // Minimum part size is 3x3", so we make TWO units joined by tabs. These can
    // be broken apart (unlikely) or cut.
    // Two is handy anyway since we need to drill tiny holes for the XT60 mount
    // and it's likely we'll damage it in the process.

    cap_tot = 85;  // minimum part size is 3" -> 76.2mm

    translate([0, 0, 0]) rotate([0, 0, 0]) cap_want();
    translate([cap_tot, width + 2 * thick, 0]) rotate([0, 0, 180]) cap_want();

    // cutoff section for minimum part size
    translate([cap_length+5, 0, 0]) square([cap_tot - 2 * cap_length - 2 * 5, width + 2 * thick]);
    // joiner tabs
    // there are no design guidelines given for mousebites so I'm trying to not be a dick
    translate([cap_length, thick + 20, 0]) square([5, 10]);
    translate([cap_length, width - thick - 20, 0]) square([5, 10]);
    translate([cap_tot - cap_length - 5, thick + 20, 0]) square([5, 10]);
    translate([cap_tot - cap_length - 5, width - thick - 20, 0]) square([5, 10]);
}

module side_body() {
    difference() {
        polygon(points=edge_path); // frame inner space
        
        // zip tie to hold discharge cable
        // cable is about 12x6mm
        translate([307, -164, 0]) rotate([0, 0, -90-bottom_angle]) translate([-8, 12, 0]) zip_tie_hole();
    }
}

// for display and debugging
if (1 && DISPLAY) {
    %translate([0, 0, -thick]) color("red") linear_extrude(height=thick) side_body();
    %translate([0, 0, width]) color("orange", 0.5) linear_extrude(height=thick) side_body();
    %translate([0, 0, 0]) rotate([90, 0, 0]) color("yellow") linear_extrude(height=thick) top_plate();
    %translate([rear_start[0], 0, 0]) rotate([90, 0, 90-rear_angle]) color("green") linear_extrude(height=thick) rear_plate();
    %translate([shock_start[0], shock_start[1], 0]) rotate([90, 0, 90-shock_angle]) color("blue", 0.5) linear_extrude(height=thick) shock_plate();
    %translate([bottom_start[0], bottom_start[1], 0]) rotate([90, 0, 90-bottom_angle]) color("violet", 0.5) linear_extrude(height=thick) bottom_plate();
    %translate([cap_start[0] - thick, cap_start[1], -thick]) rotate([90, 0, 90-cap_angle]) color("azure", 0.5) linear_extrude(height=thick) cap();

    // BMS L91*W61*H12mm
    // https://www.aliexpress.com/item/4000976874004.html?spm=a2g0o.store_pc_groupList.8148356.24.ac787abeswKOd0
    rotate([90, 0, 0]) translate([1, (width - 61) / 2, thick+2]) {
        color([1, 0, 0]) {
            cube([91, 61, 12]);
        }
    }
}

// for rendering
if (PART == "side") side_body();
if (PART == "top") top_plate();
if (PART == "bottom") bottom_plate();
if (PART == "shock") shock_plate();
if (PART == "rear") rear_plate();
if (PART == "cap") cap();
