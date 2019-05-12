// FilaMecanum OpenSCAD source code
// Project Home: https://hackaday.io/project/165330
// Author: https://hackaday.io/daren

clearance=0.2; 
filament_count=60; // number of filaments
$fn=filament_count; // circle complexity, if a multiple of filament count, things line up nicely
wall_thickness=2.0; // for the strongest part, keep this as a multiple of nozzle size
filament_r=3.15/2; // filament radius, oversize as it's reduced to 6 sides.
filament_depth=filament_r*4; // filament depth

rim_ir=72/2+clearance; // rim inside radius
rim_or=rim_ir+wall_thickness; // rim outside radius
rim_er=rim_ir+filament_depth+wall_thickness/2; // rim edge radius
rim_h=rim_or*1.25; // rim height, defined as multiple of rim_or, and so the aspect ratio.
hub_offset=6; // offset for hub mount flange to allow for hub thickness


// needed calculated values
rim_hyp=sqrt(rim_er*rim_er+(rim_h*0.85/2)*(rim_h*0.85/2))-filament_depth;
rim_angle=atan((rim_er*2)/(rim_h*0.85));
rim_edge_z=sin(rim_angle)*(filament_r*2+wall_thickness*1.0);
rim_edge_x=cos(rim_angle)*(filament_r*2+wall_thickness*1.0);

extra=0.01;
clearance=0.2; 

rim();
fit();
module fit() {
	translate([rim_h,0,rim_h/2]) rotate([45,0,0]) scale([1,1.44,1]) cylinder(r=rim_h/2,h=1,center=true);
}
module rim() {
	difference() {
		translate([0,0,rim_h/2]) rotate_extrude(convexity=10) polygon(points=[
			[rim_ir,rim_h/2-wall_thickness*1.5],
			[rim_er-rim_edge_x-wall_thickness,rim_h/2],
			[rim_er-rim_edge_x,rim_h/2],
			[rim_er,rim_h/2-rim_edge_z],
			[rim_or,rim_h/2-rim_edge_z*2],
			[rim_or,-rim_h/2+rim_edge_z*2],
			[rim_er,-rim_h/2+rim_edge_z],
			[rim_er-rim_edge_x,-rim_h/2],
			[rim_er-rim_edge_x-wall_thickness,-rim_h/2],
			[rim_ir,-rim_h/2+wall_thickness*1.5],
			[rim_ir,-hub_offset-wall_thickness*3],
			[rim_ir-wall_thickness,-hub_offset-wall_thickness],
			[rim_ir-wall_thickness,-hub_offset],
			[rim_ir,-hub_offset],
		]);
		translate([0,0,rim_h/2]) for( j=[-1,1]) translate([0,0,j*rim_h/2*0.15-j*rim_edge_z/2.5]) for (i=[0:filament_count]) rotate([0,0,i*360/filament_count]) translate([0,0,0]) rotate([rim_angle,0,0]) translate([0,0,j*(rim_hyp+filament_depth/2)]) rotate([0,0,30]) #cylinder(r=filament_r,h=filament_depth,$fn=6,center=true);
		
	}
}

