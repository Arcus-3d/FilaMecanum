


// FilaMecanum OpenSCAD source code
// Project Home: https://hackaday.io/project/165330
// Author: https://hackaday.io/daren
 
// Not really parametric.  You'll need to tweak multiple variables here if you change something.
use <./involute_gears.scad>

$fn=120;
wall_thickness=2.4;
filament_r=2.95/2;

bearing_r=17.3/2;
bearing_h=12;

hub_r=76/2;
hub_h=hub_r*1.0;
rim_r=hub_r+wall_thickness;
rim_h=rim_r*1.6;
tire_aspect=1.2;
tire_overhang=rim_h/8;

filament_count=60;
filament_depth=5;
filament_angle=124;
extra=0.01;

pressure_angle=24;
clearance=0.2; // extra depth at the base of the gear profile	
backlash=0.1; // inter-tooth clearance following the tooth profile.
input_pitch=0.95; //diametric pitch = teeth/diam
input_twist=200;
num_planets=3;
// (ring_teeth - sun_teeth) must be an even number for planet_teeth to work!
ring_teeth=66; // needs to be divisable by both <num_planets> and 2.
sun_teeth=30; // needs to be divisable by both <num_planets> and 2.
sun_bore_r=6/2+clearance/2;
sun_pin_r=2/2+clearance/2;

output_teeth=ring_teeth+num_planets;
output_twist=-200;
output_pitch = input_pitch*output_teeth/(ring_teeth-num_planets/3.0);

planet_teeth=(ring_teeth-sun_teeth)/2;
planet_bearing_r=13/2+clearance/4;
planet_bearing_h=5+clearance;
orbit_r=((planet_teeth+sun_teeth)/input_pitch)/2;

ring_gear_h=6;
ring_gear_r=ring_teeth/input_pitch/2;
motor_pilot_h=2.2;
motor_pilot_r=25/2+clearance/2;
motor_bolt_spacing=27;
motor_bolt_r=4/2;


//view_assembly(explode=0);
//cross_section();
rim(side=1);
//motor_ring();
//sun();
//planet();



module cross_section() {
	intersection() {
		rotate([0,0,15]) view_assembly();
		cube([10,1000,1000],center=true);
	}
}


module view_assembly(explode=0) {
	translate([0,0,motor_pilot_h+extra]) {
		if (0) translate([0,0,explode]) rotate([0,0,0]) sun();
		for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-1)]) translate([orbit_r,0,explode*2+clearance]) rotate([0,0,0]) planet();
	}
	if (1) translate([0,0,hub_h+bearing_h/2+motor_pilot_h+wall_thickness+explode*4]) {
		rotate([180,0,360/output_teeth/1.01]) rim(display=0);
	}
	if (0) translate([0,0,-clearance]) motor_ring();
}

module motor_ring() {
	spool_offset=0.0;
	total_height=ring_gear_h+motor_pilot_h; 
	difference() {
		// body
		translate([0,0,total_height/2]) cylinder(r=ring_gear_r+wall_thickness, h=total_height,center=true);
		// bolt holes
		for (xnum=[-1,1]) for (ynum=[-1,1]) {
			translate([xnum*motor_bolt_spacing/2,ynum*motor_bolt_spacing/2,motor_pilot_h/2]) {
				cylinder(r=motor_bolt_r+extra, h=motor_pilot_h+extra, center=true);
				translate([0,0,motor_pilot_h-motor_bolt_r+extra]) cylinder(r2=motor_bolt_r*2,r1=motor_bolt_r, h=motor_bolt_r, center=true);
			}
			
		}
		// stepper center pilot
		translate([0,0,motor_pilot_h/2]) cylinder(r=motor_pilot_r,h=motor_pilot_h+extra*4,center=true);
		// gear cutout
		rotate([0,0,360/ring_teeth/1.875]) translate([0,0,motor_pilot_h]) gear(number_of_teeth=ring_teeth, diametral_pitch=input_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra*2, gear_thickness=ring_gear_h+extra*2,clearance=0,addendum_adjustment=1.15,twist=input_twist/ring_teeth,backlash=-backlash, pressure_angle=pressure_angle );
	}
}

module sun() {
	rotate([0,0,360/sun_teeth/1.060]) difference() {
		gear(number_of_teeth=sun_teeth, diametral_pitch=input_pitch, hub_diameter=input_pitch*sun_teeth, hub_thickness=ring_gear_h-clearance, bore_diameter=sun_bore_r*2, rim_thickness=ring_gear_h-clearance, rim_width=0, gear_thickness=ring_gear_h-clearance,clearance=clearance, twist=-input_twist/sun_teeth,backlash=backlash, pressure_angle=pressure_angle);
		translate([0,0,ring_gear_h/4]) cube([sun_bore_r*3.5,sun_pin_r*2+clearance,ring_gear_h],center=true);
	}
}

module planet() {
	difference() {
		union() {
			rotate([0,0,input_twist/planet_teeth]) gear(number_of_teeth=planet_teeth, diametral_pitch=input_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h, gear_thickness=ring_gear_h,clearance=clearance, backlash=backlash, twist=input_twist/planet_teeth,pressure_angle=pressure_angle);
			translate([0,0,ring_gear_h]) gear(number_of_teeth=planet_teeth, diametral_pitch=output_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h, gear_thickness=ring_gear_h,clearance=clearance, backlash=backlash, twist=output_twist/planet_teeth,pressure_angle=pressure_angle);
		}
		translate([0,0,ring_gear_h]) cylinder(r=planet_bearing_r,h=planet_bearing_h+extra,center=true);
		translate([0,0,ring_gear_h]) cylinder(r=planet_bearing_r-wall_thickness/2,h=ring_gear_h*2+extra,center=true);
	}
}

module rim(display=1,side=1) {
	difference() {
		// body
		rotate([0,0,-1.5]) union() {
			// main body
			translate([0,0,rim_h/2]) cylinder(r=rim_r,h=rim_h,$fn=filament_count,center=true);
			// top rim
			translate([0,0,rim_h-filament_r*2.5/2]) cylinder(r1=rim_r+filament_depth/1.44+wall_thickness,r2=rim_r+filament_depth/2/1.44+wall_thickness,h=filament_r*2.5,$fn=filament_count,center=true);
			// top flange
			translate([0,0,rim_h-filament_r*2.5-filament_depth*1.5/2]) cylinder(r2=rim_r+filament_depth/1.44+wall_thickness,r1=rim_r,h=filament_depth*1.5,$fn=filament_count,center=true);
			// bottom rim
			translate([0,0,filament_r*2.5/2]) cylinder(r2=rim_r+filament_depth/1.44+wall_thickness,r1=rim_r+filament_depth/2/1.44+wall_thickness,h=filament_r*2.5,$fn=filament_count,center=true);
			// bottom flange
			translate([0,0,filament_r*2.5+filament_depth*1.5/2]) cylinder(r1=rim_r+filament_depth/1.44+wall_thickness,r2=rim_r,h=filament_depth*1.5,$fn=filament_count,center=true);
		}
		// top rim cutout
		translate([0,0,rim_h-(rim_h-hub_h-bearing_h/2)/2+extra]) cylinder(r2=hub_r+filament_depth,r1=bearing_r,h=rim_h-hub_h-bearing_h/2+extra,$fn=filament_count,center=true);
		// bottom rim cutout
		translate([0,0,(rim_h-hub_h)/2-extra]) cylinder(r1=hub_r+filament_depth,r2=bearing_r,h=rim_h-hub_h+extra*2,$fn=filament_count,center=true);
		// hub cutout - bearing block
		difference() {
			translate([0,0,rim_h-hub_h/2+bearing_h]) cylinder(r=hub_r,h=hub_h+extra,$fn=filament_count,center=true);
			translate([0,0,rim_h-hub_h+bearing_h/2+wall_thickness/8]) cylinder(r=bearing_r+wall_thickness*2,h=bearing_h+wall_thickness/4,center=true);
		}
		// filament holes
		if (1) for (i=[0:filament_count]) rotate([0,0,360/filament_count*i+360/filament_count/1]) translate([rim_r+filament_depth+wall_thickness/2+tire_overhang*1.44,0,rim_h/2]) rotate([45*side,0,0]) rotate([90,0,0]) scale([1/tire_aspect/1.44,1,1]) for (j=[-1,1]) rotate([0,0,filament_angle*j]) translate([rim_h/2*1.44+tire_overhang*1.44,0,0]) rotate([90,0,0]) scale([1,1/1.44,1]) translate([0,0,filament_depth*1.44*tire_aspect/2*-j]) #cylinder(r=filament_r,h=filament_depth*18.44*tire_aspect,$fn=8,center=true);
		// bearing cutout
		if (1) translate([0,0,rim_h-hub_h+bearing_h/2-clearance*2]) cylinder(r=bearing_r,h=bearing_h+extra,$fn=filament_count,center=true);
		if (1) translate([0,0,rim_h-hub_h+bearing_h+wall_thickness/4-clearance*2]) cylinder(r2=bearing_r-wall_thickness/2,r1=bearing_r,h=wall_thickness/2,$fn=filament_count,center=true);
		// gear drive + bearing cutout
		difference() {
			translate([0,0,rim_h-hub_h+bearing_h-ring_gear_h-extra/2]) gear(number_of_teeth=output_teeth, diametral_pitch=output_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra*4, gear_thickness=ring_gear_h+extra*4,clearance=0, addendum_adjustment=1.15, backlash=-backlash, twist=output_twist/output_teeth,pressure_angle=pressure_angle);
			translate([0,0,rim_h-hub_h+bearing_h-ring_gear_h+wall_thickness-clearance*2]) cylinder(r=bearing_r+wall_thickness*2,h=bearing_h+clearance,center=true);
			translate([0,0,rim_h-hub_h+bearing_h-ring_gear_h+wall_thickness-clearance*2]) cylinder(r2=bearing_r+wall_thickness,r1=bearing_r+wall_thickness*3.5,h=bearing_h+clearance,center=true);
		}
		// tire display
		if (display) %difference() {
			for (i=[0:filament_count]) rotate([0,0,360/filament_count*i+360/filament_count/1]) translate([rim_r+filament_depth+wall_thickness/2+tire_overhang*1.44,0,rim_h/2]) rotate([45*side,0,0]) rotate([90,0,0]) scale([1/tire_aspect/1.44,1,1]) difference() {
				cylinder(r=rim_h/2*1.44+filament_r/2+tire_overhang*1.44,h=filament_r,center=true);
				cylinder(r=rim_h/2*1.44-filament_r/2+tire_overhang*1.44,h=filament_r+extra*4,center=true);
			}
			translate([0,0,rim_h/2]) cylinder(r=rim_r,h=rim_h+extra*4,center=true);
		}

	}
}

