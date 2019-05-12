


// FilaMecanum OpenSCAD source code
// Project Home: https://hackaday.io/project/165330
// Author: https://hackaday.io/daren
 
// Not really parametric.  You'll need to tweak multiple variables here if you change something.


wall_thickness=.8*1.44;
shaft_r=5/2;
rim_r=22;
rim_h=3;
hub_r=rim_r/2;
hub_h=rim_h*3.15;
filament_count=30;
filament_r=2.95/2;
filament_depth=6;
extra=0.01;

rim(side=-1);
//rim(side=1);


module rim(display=0,side=1) {
	difference() {
		rotate([0,0,360/filament_count/5]) hull() {
			translate([0,0,hub_h+filament_r/2+wall_thickness/2]) cylinder(r1=rim_r,r2=rim_r-filament_r*2.2,h=filament_r+wall_thickness,$fn=filament_count,center=true);
			translate([0,0,extra/2]) cylinder(r=hub_r,h=extra,$fn=filament_count,center=true);
		}
		#for (i=[0:filament_count]) rotate([0,0,360/filament_count*i+360/filament_count/1]) translate([rim_r*1.25,0,0]) rotate([side*45,0,0]) rotate([0,-135,0]) translate([rim_r/1.25,0,0]) rotate([0,-11,0]) translate([0,0,-filament_depth*0.2]) cylinder(r=filament_r,h=filament_depth*1.2,$fn=8,center=true);
		rotate([0,0,360/filament_count/5]) translate([0,0,hub_h-wall_thickness*3]) hull() {
			translate([0,0,hub_h+filament_r/2+wall_thickness/2]) cylinder(r1=rim_r,r2=rim_r-filament_r*2.2,h=filament_r+wall_thickness,$fn=filament_count,center=true);
			translate([0,0,extra/2]) cylinder(r=hub_r,h=extra,$fn=filament_count,center=true);
		}
		for (i=[0:6]) rotate([0,0,360/6*i]) translate([hub_r/1.44,0,0]) hull() {
			rotate([0,0,30]) cylinder(r=hub_r/4,h=extra,$fn=6,center=true);
			translate([rim_r/2.6/4,-side*rim_r/2,hub_h*2]) rotate([0,0,0]) cylinder(r=rim_r/4,h=extra,$fn=6,center=true);
		}
		translate([0,0,hub_h/2]) cylinder(r=shaft_r,h=hub_h+extra,$fn=filament_count,center=true);
		if (display) for (i=[0:filament_count]) rotate([0,0,360/filament_count*i+360/filament_count/1]) translate([rim_r*1.25,0,0]) rotate([45,0,0]) rotate([90,0,0]) scale([1,1.25,1]) difference() {
			cylinder(r=rim_r/1.44+filament_r*1.44,h=filament_r,center=true);
			cylinder(r=rim_r/1.44,h=filament_r+extra,center=true);
		}

	}
}

