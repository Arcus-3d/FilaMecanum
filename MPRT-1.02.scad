// MPRT - Modified planetary robotics transmission OpenSCAD source

// Project home: https://hackaday.io/project/164732
// Author: https://hackaday.io/daren
// Version 1.02
//
// Creative Commons License exists for this work. You may copy and alter the content
// of this file for private use only, and distribute it only with the associated
// MPRT content. This license must be included with the file and content.
// For a copy of the current license, please visit http://creativecommons.org/licenses/by-sa/3.0/

// uncomment each of these, render, print.

// sun();
//planet();
// housing_ring();
// need to flip the output ring for printing
//translate([0,0,output_pilot_h+ring_gear_h]) rotate([0,180,0]) output_ring();

// visualization. Set output_ring_h=0 for a view of the gears.
view_assembly(explode=0);
//view_cross_section(explode=0);

use <./involute_gears.scad>  // This is not mine.  I've edited it to make it not error in later versions of OpenSCAD though.

// accuracy and such
extra=0.02; // for differencing
$fs=.01; // circle/face accuracy
$fn=120; // circle default facets

//settings you can mess with.

// housing/output/input settings

output_r=72/2-0.1; // matches the rim.
output_pilot_h=3; // thick enough overall to seat either one, or two bearings.
output_pilot_r=17.3/2; // 17mm bearing plus clearance.

sun_bore_r=6.15/2; // 6mm shaft plus clearance.
sun_bore_d_shaft=false; // set true for a D shaft
sun_bore_pin_shaft=true; // set true for a pin through the shaft
sun_bore_pin_r=2.4/2; // pin radius
sun_bore_pin_h=2.4/2+1.1; // top of pin slot offset from base of sun gear.
sun_bore_pin_l=sun_bore_r*5; // pin length

housing_r=72/2-0.8; // clears the rim.
housing_pilot_h=2.3; // matches my motor.
housing_pilot_r=25.3/2; // motor pilot + clearance
gear_wall=3.2; // gear edge thickness


// gear settings
num_planets=6; // planet count for calculations
planet_divisor=2; // planet count divisor for visualization (skipping planets)
// ring_teeth - sun_teeth must be an even number!
sun_teeth=36; // needs to be divisable by both <num_planets> and 2.
ring_teeth=72; // needs to be divisable by both <num_planets> and 2.
ring_gear_h=5; // total height adds pilot heights to this

// these are good numbers for small-ish 3D printed gears.
pressure_angle=24;
clearance=0.2; // extra space at the base/tip of the gear tooth and betwen gears vertically. The base and tip clearance helps with the limitations you hit for corner radii while 3D printing.
backlash=0.1; // inter-tooth clearance along the tooth profile.
input_twist=150; // helical gears if > 0.  Straight cut gears if 0.


// calculated stuff you should probably leave alone
ring_gear_r=housing_r-gear_wall; // gear radius on pitch line
input_pitch=ring_teeth/ring_gear_r/2;
planet_teeth=(ring_teeth-sun_teeth)/2;
output_teeth=ring_teeth+num_planets;
output_twist=-input_twist*1.2;
idler_teeth=sun_teeth+num_planets;
output_pitch = input_pitch*(planet_teeth+idler_teeth)/(planet_teeth+sun_teeth);
orbit_r=((planet_teeth+sun_teeth)/input_pitch)/2;


// center cutouts for lighter gears
planet_cutout_r=planet_teeth/output_pitch/2-gear_wall;
idler_cutout_r1=idler_teeth/output_pitch/2-gear_wall;
idler_cutout_r2=idler_teeth/output_pitch/2-gear_wall/1.5;


/// assembly view.
module view_cross_section(explode=0) {
	intersection() {
		rotate([0,0,0]) view_assembly(explode=explode);
		cube([1000,0.1,1000],center=true);
	}
}


module view_assembly(explode=0) {
	translate([0,0,housing_pilot_h+extra+explode]) {
		if(1) rotate([0,0,360/sun_teeth/2*(planet_teeth % 2)]) translate([0,0,clearance/2]) sun();
		translate([0,0,ring_gear_h-clearance/2+explode*2]) rotate([0,0,360/idler_teeth/2*(planet_teeth % 2 - 1)]) idler();
		if (1) for (planetnum=[1:planet_divisor:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-1)]) translate([orbit_r,0,clearance/2+explode]) rotate([0,0,0]) planet();
	}
	if (1) translate([0,0,housing_pilot_h+ring_gear_h+clearance/2+explode*4]) {
		rotate([0,0,360/output_teeth/1.01]) output_ring();
		translate([0,0,housing_pilot_h+1.2+explode]) bearing();
		translate([0,0,housing_pilot_h+1.2+6+explode*2]) bearing();
	}
	if (1) housing_ring();

	first_ratio=(1+ring_teeth/sun_teeth);
	second_ratio=1/(1-ring_teeth/output_teeth);
	final_ratio=first_ratio*second_ratio;
	echo(str("Static Ring Teeth: " , ring_teeth));
	echo(str("Output Ring Teeth: " , output_teeth));
	echo(str("Sun Teeth: " , sun_teeth));
	echo(str("Idler Teeth: " , idler_teeth));
	echo(str("Planet Teeth: " , planet_teeth));
	echo(str("Planet Count: ", num_planets ));	
	echo(str("Input Pitch: " , input_pitch));
	echo(str("Output Pitch: " , output_pitch));
	echo(str("First Stage: ", first_ratio, ":1"));
	echo(str("Second Stage: ", second_ratio, ":1"));
	echo(str("Final Drive: ", final_ratio,":1"));
}

module output_ring(ring_gear_h=ring_gear_h,output_pilot_h=output_pilot_h,output_pilot_r=output_pilot_r) {
	difference() {
		// body
		translate([0,0,ring_gear_h/2+output_pilot_h/2]) cylinder(r=output_r,h=ring_gear_h+output_pilot_h-extra,center=true);
		// gear cutout
		difference() {
			translate([0,0,-extra/2]) gear(number_of_teeth=output_teeth, diametral_pitch=output_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra, gear_thickness=ring_gear_h+extra,clearance=0, addendum_adjustment=1.15, backlash=-backlash, twist=output_twist/output_teeth,pressure_angle=pressure_angle);
			translate([0,0,ring_gear_h/2]) cylinder(r1=idler_cutout_r1-clearance*2,r2=idler_cutout_r2-clearance*2,h=ring_gear_h+extra,center=true);
		}
		// pilot cutout
		translate([0,0,ring_gear_h+output_pilot_h/2]) cylinder(r=output_pilot_r,h=output_pilot_h+extra,center=true);
		translate([0,0,ring_gear_h/2+output_pilot_h/2+1]) cylinder(r=output_pilot_r,h=output_pilot_h+ring_gear_h+extra,center=true);
		translate([0,0,1/2]) cylinder(r1=output_pilot_r-1,r2=output_pilot_r,h=1+extra,center=true);
	}
}

module planet() {
	rotate([0,0,360/sun_teeth/1]) gear(number_of_teeth=planet_teeth, diametral_pitch=input_pitch, hub_diameter=0, bore_diameter=planet_cutout_r*2, rim_thickness=ring_gear_h-clearance/2, gear_thickness=ring_gear_h-clearance/2,clearance=clearance, backlash=backlash, twist=input_twist/planet_teeth,pressure_angle=pressure_angle);
	translate([0,0,ring_gear_h-clearance]) gear(number_of_teeth=planet_teeth, diametral_pitch=output_pitch, hub_diameter=0, bore_diameter=planet_cutout_r*2, rim_thickness=ring_gear_h-clearance/2, gear_thickness=ring_gear_h-clearance/2,clearance=clearance, backlash=backlash, twist=output_twist/planet_teeth,pressure_angle=pressure_angle);
}

module housing_ring() {
	total_height=ring_gear_h+housing_pilot_h; 
	translate([0,0,total_height/2]) difference() {
		// body
		cylinder(r=housing_r, h=total_height,center=true);
		translate([0,0,-total_height/2]) {
			// gear cutout
			rotate([0,0,360/ring_teeth/1.875]) translate([0,0,housing_pilot_h]) gear(number_of_teeth=ring_teeth, diametral_pitch=input_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra*4, gear_thickness=ring_gear_h+extra*4,clearance=0,addendum_adjustment=1.15,twist=input_twist/ring_teeth,backlash=-backlash, pressure_angle=pressure_angle );
			// center pilot cutout
			translate([0,0,housing_pilot_h/2]) cylinder(r=housing_pilot_r,h=housing_pilot_h+extra*4,center=true);
		}
	}
}

module idler() {
	difference() {
		rotate([0,0,360/idler_teeth/1]) gear(number_of_teeth=idler_teeth, diametral_pitch=output_pitch, hub_diameter=output_pitch*sun_teeth, hub_thickness=ring_gear_h-clearance/2, bore_diameter=0, rim_thickness=ring_gear_h-clearance/2, rim_width=0, gear_thickness=ring_gear_h-clearance/2,clearance=clearance, twist=-output_twist/idler_teeth,backlash=backlash, pressure_angle=pressure_angle);
		translate([0,0,ring_gear_h/2-clearance/4]) cylinder(r1=idler_cutout_r1,r2=idler_cutout_r2,h=ring_gear_h-clearance/2+extra,center=true);
	}
}
module sun() {
	difference() {
		union() {
			rotate([0,0,360/sun_teeth/1]) gear(number_of_teeth=sun_teeth, diametral_pitch=input_pitch, hub_diameter=input_pitch*sun_teeth, hub_thickness=ring_gear_h-clearance/2, bore_diameter=sun_bore_r*2, rim_thickness=ring_gear_h-clearance/2, rim_width=ring_gear_r/2-sun_bore_r*2.5, gear_thickness=ring_gear_h-clearance/2+1,clearance=clearance, twist=-input_twist/sun_teeth,backlash=backlash, pressure_angle=pressure_angle);
			// D shaft flat
			if (sun_bore_d_shaft) translate([sun_bore_r*2/1.9,0,ring_gear_h/2-clearance/4]) cube([sun_bore_r*2/5,sun_bore_r,ring_gear_h-clearance/2],center=true);
		}
		if (sun_bore_pin_shaft) translate([0,0,sun_bore_pin_h]) hull() {
			rotate([0,90,0]) cylinder(r=sun_bore_pin_r,h=sun_bore_pin_l,center=true);
			translate([0,0,-sun_bore_pin_h]) cube([sun_bore_pin_l,sun_bore_pin_r*2,extra],center=true);
		}
	}
}

module bearing(r1=6/2,r2=17/2,h=6){
	intersection() {
		difference() {
			union() {
				color("grey") difference() {
					cylinder(r=r2,h=h,center=true);
					cylinder(r=r2/1.15,h=h+extra,center=true);
				}
				color("grey") difference() {
					cylinder(r=r1/.7,h=h,center=true);
					cylinder(r=r1/2,h=h+extra,center=true);
				}
				color("orange") cylinder(r=r2-extra,h=h*.9,center=true);
			}
			color("grey") cylinder(r=r1,h=h+extra*2,center=true);
			translate([0,0,h/2.2]) color("grey") cylinder(r1=0,r2=r1*2,h=h,center=true);
			translate([0,0,-h/2.2]) color("grey") cylinder(r2=0,r1=r1*2,h=h,center=true);
		}
		translate([0,0,h/2.2]) color("grey") cylinder(r2=0,r1=r2*2,h=h*2,center=true);
		translate([0,0,-h/2.2]) color("grey") cylinder(r1=0,r2=r2*2,h=h*2,center=true);
	}
}

