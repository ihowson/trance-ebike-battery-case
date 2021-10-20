// all dimensions are in millimetres

// NOTE: import order matters to avoid name collisions
// see https://github.com/openscad/openscad/issues/1936
use <BOSL2/std.scad>
use <scad-utils/morphology.scad>

//material_thickness = 4.55;
material_thickness = 3.0;
bracket_d = 6.35;
bracket_e = 5.16;

screw_offset_large = material_thickness + bracket_d;
screw_offset_small = material_thickness + bracket_e;

//screw_edge_buffer = screw_offset*2;
screw_interval = 25;

// inside width of the box -- 65mm for cells plus a bit for welding, padding and cabling
width = 80;

// original measurements
//edge_path = [[0,0],[405,0],[414,-84],[334,-124],[309, -166],[0,-25]];
// squeezed in 1mm for safety
edge_path =   [[0,0],[403,0],[412,-83],[332,-122],[307, -164],[0,-25]];

top_length = 403;

rear_coords = [[403,0],[412,-83]];
rear_length = norm(rear_coords[0] - rear_coords[1]);
rear_angle = atan2(rear_coords[1][0] - rear_coords[0][0], rear_coords[1][1] - rear_coords[0][1]);

sup_coords = [[412,-83], [332,-122]];
sup_length = norm(sup_coords[0] - sup_coords[1]);
sup_angle = atan2(sup_coords[1][0] - sup_coords[0][0], sup_coords[1][1] - sup_coords[0][1]);

slp_coords = [[332,-122],[307, -164]];
slp_length = norm(slp_coords[0] - slp_coords[1]);
slp_angle = atan2(slp_coords[1][0] - slp_coords[0][0], slp_coords[1][1] - slp_coords[0][1]);

bottom_coords = [[307, -164], [0,-25]];
bottom_length = norm(bottom_coords[1] - bottom_coords[0]);
bottom_angle = atan2(bottom_coords[1][0] - bottom_coords[0][0], bottom_coords[1][1] - bottom_coords[0][1]);


chop_length = material_thickness + 2;

module row_holes(width, buffer, n, rshove=0) {
    spacing = (width - rshove - 2 * buffer) / (n - 1);
    for (i = [0:n-1]) {
        translate([buffer + i * spacing, 0]) {
            circle(d=3.6, $fn=32);
        }
    }
}

module strap_hole_pair(delta) {
    centre_line = width / 2;

    translate([0, centre_line - delta/2, 0])
        square([25, 4], center=true);
    translate([0, centre_line + delta/2, 0])
        square([25, 4], center=true);
}

module xt60_panel() {
    square([15.8, 8.4], center=true);  // nominally 15.5x8.1
    translate([-10.25, 0, 0]) circle(d=3.2, $fn=32);
    translate([10.25, 0, 0]) circle(d=3.2, $fn=32);
}

module top_plate() {
    strap_delta = 38;
    difference() {
        rounding(r=3, $fn=32) square([top_length, width]);

        translate([40, 0, 0]) strap_hole_pair(strap_delta);
        translate([150, 0, 0]) strap_hole_pair(strap_delta);
        translate([260, 0, 0]) strap_hole_pair(strap_delta);
        translate([top_length-57, 0, 0]) strap_hole_pair(strap_delta); // special placement to fit inside 'handle'      
        
        translate([0, screw_offset_small, 0])
            row_holes(width=top_length, buffer=10, n=13, rshove=12);
        translate([0, width-screw_offset_small, 0])
            row_holes(width=top_length, buffer=10, n=13, rshove=12);
    }
}

module rear_plate() {
    strap_delta = 35;

    difference() {
        rounding(r=3, $fn=32) square([rear_length, width]);

        // chop off the top meterial_thickness+2mm to make space for the top plate
        square([chop_length, width], center=false);

        translate([rear_length/2, 0, 0]) strap_hole_pair(strap_delta);
    
        translate([0, screw_offset_small, 0])
            row_holes(width=rear_length, buffer=12, n=3);
        translate([0, width-screw_offset_small, 0])
            row_holes(width=rear_length, buffer=12, n=3);
    }
}

module shock_upper_plate() {    
    difference() {
        square([sup_length, width]);
    
        // chop off the top material_thickness+2mm to make space for the rear plate
        // bottom edge
        square([chop_length, width], center=false);
        // top edge
        translate([sup_length-chop_length, 0, 0]) square([chop_length, width], center=false);

        rotate([0, 0, 0])
        translate([0, screw_offset_small, 0])
            row_holes(width=sup_length, buffer=13, n=3, rshove=5);
        translate([0, width-screw_offset_small, 0])
            row_holes(width=sup_length, buffer=13, n=3, rshove=5);
    }
}


module shock_lower_plate(length) {    
    difference() {
        square([slp_length, width]);

       // chop off the bottom material_thickness+2mm to make space for the bottom plate
        translate([slp_length-chop_length, 0, 0]) square([chop_length, width], center=false);
        
        translate([0, screw_offset_small, 0])
            row_holes(width=slp_length, buffer=17, n=2, rshove=-4);
        translate([0, width-screw_offset_small, 0])
            row_holes(width=slp_length, buffer=17, n=2, rshove=-4);
    }
}

module bottom_plate(length) {
    strap_delta = 49;

    difference() {
        rounding(r=3, $fn=32) square([bottom_length, width]);

        translate([bottom_length*(1/7), 0, 0]) strap_hole_pair(strap_delta);
        translate([bottom_length*0.5, 0, 0]) strap_hole_pair(strap_delta);
        translate([bottom_length*(6/7), 0, 0]) strap_hole_pair(strap_delta);
    
        rotate([0, 0, 0])
        translate([0, screw_offset_small, 0])
            row_holes(width=bottom_length, buffer=12, n=10, rshove=10);
        translate([0, width-screw_offset_small, 0])
            row_holes(width=bottom_length, buffer=16, n=10, rshove=10);
        
      //          translate([307, -164, 0]) {
      //      rotate([0, 0, -90-bottom_angle]) {
    
    // discharge cable hole
        translate([bottom_length-12, -2.5, 0]) rounding(r=2.5) square([15, 9]);
        translate([bottom_length-10, 9, 0]) square([5, 3.5]); // ziptie hole
    }
}

module side_body() {
    screw_inset = screw_offset_large+material_thickness;
    difference() {
        rounding(r=screw_offset_large / 2, $fn=32) {
            fillet(r=50, $fn=64) { // nice gentle curve around the shock
                polygon(points=edge_path); // frame inner space
            }
        }
        
        // charge connector and switch
        translate([30, -18, 0]) rotate([0, 0, 90]) xt60_panel();
    
        // top row holes
        translate([0, -screw_inset, 0])
            row_holes(width=top_length, buffer=10, n=13, rshove=12);

        // rear plate holes
        translate([403-screw_inset, 0, 0])
        rotate([0, 0, 90-rear_angle])
            row_holes(width=rear_length, buffer=12, n=3);

        // bottom plate holes
        translate([0, -25, 0])
        rotate([0, 0, -90-bottom_angle])
        translate([0, screw_inset, 0])
        row_holes(width=bottom_length, buffer=16, n=10, rshove=10);
        
        // lower shock plate holes
        translate([307, -164, 0])
        rotate([0, 0, -90-slp_angle])
        translate([0, screw_inset, 0])
        row_holes(width=slp_length, buffer=17, n=2, rshove=-4);
        
        // upper shock plate holes
        translate([332,-122, 0])
        rotate([0, 0, -90-sup_angle])
        translate([0, screw_inset, 0])
        row_holes(width=sup_length, buffer=13, n=3, rshove=5);
        
        // discharge cable hole
        //about 12x6mm
        translate([307, -164, 0]) {
            rotate([0, 0, -90-bottom_angle]) {
                //translate([-12, -2.5, 0]) rounding(r=2.5) square([15, 9]);
                translate([-10, 8, 0]) square([5, 3.5]); // ziptie hole
            }
        }
    }
}
/*
linear_extrude(height = material_thickness) {
    side_body();
/*        
    translate([0, 5, 0]) {
        top_plate();
    }

    translate([410, 0, 40]) rotate([0, 0, 90-rear_angle]) {
        rear_plate();
    }

    translate([367, -198, 0]) rotate([0, 0, -90-sup_angle]) {
        shock_upper_plate();
    }

    translate([380, -203, 40]) rotate([0, 0, -90-slp_angle]) {
        shock_lower_plate();
    }

    translate([-35, -105, 0]) rotate([0, 0, -90-bottom_angle]) {
        bottom_plate();
    }
}
*/

module shock_lower_plate_extra() {
    difference() {
        union() {
            shock_lower_plate();
            translate([-30, 0, 0]) square([30, width]);
        }
        // score lines
        translate([-3, 0, 0]) square([3.2, 30]);
        translate([-3, width-30, 0]) square([3.2, 30]);
    }
}

// for rendering
side_body();
//top_plate();
//bottom_plate();
//shock_lower_plate();
//shock_upper_plate();
//rear_plate();
//shock_lower_plate_extra();

// BMS L91*W61*H12mm
// https://www.aliexpress.com/item/4000976874004.html?spm=a2g0o.store_pc_groupList.8148356.24.ac787abeswKOd0
/*
translate([100, 13, 10]) {
    color([1,0,0]) {
        cube([91, 61, 12]);
    }
}*/

// BACKLOG
//Interlocking edges for case to make it stronger when assembled 

// the bms doesn't really fit within the screws. do you make the case wider to accomodate? might even be better to put it on the side but move it to the bottom so it doesn't collide with your knees
