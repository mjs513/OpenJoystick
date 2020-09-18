// Wall thickness
wt = 5;
// Pre-drill hole/groove depth
pd_groove_z = 2;
pd_groove_x = 1;
pd_hole_r = 1.5;
pd_hole_z = pd_groove_z;
// Grid spacing for the straight pre-drill grooves
pd_grid_xy = 10;
// Leave this much room around the edge without pre-drill grooves/holes.
pd_grid_clearance = 10;
// A list of radii for the circular pre-drill grooves
circles_r = [10, 20, 30, 40];
// Overall width/height
unit_xy = 100;
unit_z = 70;
lid_screw_offset_x = 8;

// grid_screw is an M3x20 cup head bolt by default
module lid_screw() {
    head_r = 3;
    head_z = 3;
    shaft_r = 1.5;
    shaft_z = 20;
    cylinder(r=head_r, h=head_z);
    translate([0,0,head_z]) cylinder(r=shaft_r, h=shaft_z, $fn=10);
}

// base is the body of the module. Basically everything except the lid.
module base() {
    difference () {
        cube([unit_xy, unit_xy, unit_z-wt/2]);
        translate([wt, wt, wt]) cube([unit_xy-2*wt, unit_xy-2*wt, unit_z]);
    }
}
base();

module lid_whole() {
    union()
    {
        cube([unit_xy, unit_xy, wt/2]);
        translate([wt,wt,wt/2])
            cube([unit_xy-wt*2, unit_xy-wt*2, wt/2]);
    }
}

// lid_lines is half of the straight lines in the underside of the lid
module lid_lines() {
    for (x = [pd_grid_clearance:pd_grid_xy:unit_xy-pd_grid_clearance]) {
        translate([x-pd_groove_x/2, pd_grid_clearance, 0]) cube([pd_groove_x, unit_xy-2*pd_grid_clearance, 10]);
    }
}

// lid_grid is subtracted from the lid to provide the grid
// lines to assist with drilling accurately spaced holes or
// punching out neat sections.
module lid_grid() {
    lid_lines();
    translate([unit_xy, 0, 0]) rotate([0,0,90]) lid_lines();
    for (x = [pd_grid_clearance:pd_grid_xy:unit_xy-pd_grid_clearance]) {
        for (y = [pd_grid_clearance:pd_grid_xy:unit_xy-pd_grid_clearance]) {
            translate([x, y, 0]) cylinder(r=pd_hole_r, h=10);
        }
    }
}

// lid_circles is subtracted from the underside of the lid
// to make it easier to punch out portions of the lid to mount
// stuff.
module lid_circles() {
    // This should be 100, but it makes my laptop cry.
    // Consider doing this with two subtracted cylinders
    // rather than a circle of cones.
    cone_n = 10;

    for (r = circles_r) {
        difference() {
            cylinder(r=r+pd_groove_x/2, h=10);
            cylinder(r=r-pd_groove_x/2, h=10);
        }
    }
}

// lid is the lid of a module. The grooves argument lets you turn off the grooves for improved
// rendering speed.
module lid(grooves = 1) {
    difference() {
        lid_whole();
        lsox = lid_screw_offset_x;
        translate([lsox, lsox,0]) lid_screw();
        translate([unit_xy-lsox, lsox,0]) lid_screw();
        translate([unit_xy-lsox, unit_xy-lsox,0]) lid_screw();
        translate([lsox, unit_xy-lsox,0]) lid_screw();

        if (grooves) {
            translate([unit_xy/2, unit_xy/2, wt-pd_groove_z]) lid_circles();
            translate([0, 0, wt-pd_hole_z]) lid_grid();
        }
    }
}

// lid(0);

module assembled() {
    base();
    translate([0,unit_xy,unit_z])
        rotate([180,0,0])
            #lid();

}
// lid();
// assembled();
// base();