size_x = 110;
size_y = 45;
box_h = 40;
box_wall = 4;

//size_z = 10;

screw_r = 1.5;

include<mountingClamp.scad>;

clampWidth = 20;
shaftDiameter = 33; //25.4 ;

module pyramid(top_x,top_y, base_x, base_y, h) {
        polyhedron(
            points=[
                [base_x,base_y,0],      // the four points at base
                [base_x,-base_y,0],
                [-base_x,-base_y,0],
                [-base_x,base_y,0],
    
                [top_x,top_y,h],      // the four points at top
                [top_x,-top_y,h],
                [-top_x,-top_y,h],
                [-top_x,top_y,h], 
            ],
            faces=[
                [0,1,4], [4,1,5], // each side
                [1,2,5], [5,2,6],
                [2,3,6], [6,3,7],
                [3,0,7], [0,4,7],
                [1,0,3], [2,1,3], // two triangles for base
                [7,4,5], [7,5,6]  // two triangles for top
                ]                         
        );
}

// IR temp module
module gy906() {
  pcb_x = 11.5;
  pcb_y = 16.5;
  pcb_z = 1.5;
  union() {
    // PCB
    translate([0,0, pcb_z/2]){ 
      cube([pcb_x, pcb_y, pcb_z], true);
    }
    
    translate([0,0,-.5]){ 
      // flange
      cylinder(.5, r=5.25, $fn=50, false);
      translate([0,0,-3]) {
        // Sensor body
        cylinder(3.5, r=4.5, $fn=50, false);
        translate([0,0,-6]) {
            // cone
            cylinder(6, 8, 4.5, $fn=50, false);
        }
      }
    }
    
    // Mounting holes
    translate([3,6,-3]){
      cylinder(3, r=screw_r, $fn=50, false);
    }
    translate([-3,6,-3]){
      cylinder(3, r=screw_r, $fn=50, false);
    }
  
    // wiring
    translate([-pcb_x/2,-pcb_y/2-3, -2]){ 
      cube([pcb_x, 6, 2], false);
    }
  }
}

module vlx53L1x(thickness) {
  pcb_x = 16;
  pcb_y = 11;
  pcb_z = 1.5;
  union() {
    // PCB
    translate([0, 0, pcb_z/2]) { 
      cube([pcb_x, pcb_y, pcb_z], true);
    }
    
    // wiring
    wiring_y=4;
    translate([-pcb_x/2, pcb_y/2-wiring_y, -1.5]) { 
      cube([pcb_x, wiring_y, 1.5], false);
    }
    
    sensor_x=11.5;
    sensor_y=7;
    sensor_z=2;
    
    // Sensor
    translate([0, -(pcb_y-sensor_y)/2, -sensor_z/2]) { 
      cube([sensor_x, sensor_y, sensor_z], true);
    }

    // cone
    translate([0, -(pcb_y-sensor_y)/2, -pcb_z-thickness]) {
        pyramid(sensor_x/2, sensor_y/2, sensor_x, sensor_y, thickness);
    }
  
    // Mounting holes
    translate([-10, 0,-3]){
      cylinder(3, r=screw_r, $fn=50, false);
    }
    translate([10, 0,-3]){
      cylinder(3, r=screw_r, $fn=50, false);
    }
  }
}


module prism(l, w, h){
      polyhedron(//pt 0        1        2           3           4        5
              points=[[0,0,0], [l,0,0], [l,w/2,h], [0,w/2,h], [0,w,0], [l,w,0]],
              faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
              );
}

module box(height, wall) {
  translate([-size_x/2, -size_y/2, 0]) {
    difference(){
      cube([size_x, size_y, height]);
      translate([wall,wall, -2*wall]) cube([size_x-wall*2, size_y-wall*2, height]);
    }
  }
  
  // Screw posts
  post_r = 4+wall;
  translate([-size_x/2, -size_y/2, 0])
    cube([post_r, post_r, height], center=false);
  translate([size_x/2-post_r, -size_y/2, 0])
    cube([post_r, post_r, height], center=false);
  translate([-size_x/2, size_y/2-post_r, 0])
    cube([post_r, post_r, height], center=false);
  translate([size_x/2-post_r, size_y/2-post_r, 0])
    cube([post_r, post_r, height], center=false);

  // clamp
  tophat=5;
  translate([clampWidth/2, 0, shaftDiameter/2 + height+tophat]) {
    rotate([-90,0,90]) clamp();
  }
  widthFract=0.6;
  translate([-clampWidth/2, -(shaftDiameter*widthFract)/2, box_h ]) {
    cube([clampWidth,shaftDiameter*widthFract , tophat]);
  }
  translate([-size_x/2, -size_y/2, box_h ]) {
    prism(size_x, size_y, tophat);
  }
}

module heltec_v4() {
    pcb_thickness=1;
    pcb_w=26;
    pcb_l=50;
    conn_thickness=4;
    translate([-pcb_l/2, -pcb_w/2, -pcb_thickness]) {
        cube([pcb_l, pcb_w, pcb_thickness]);
        translate([-5,5/2, -conn_thickness]) cube([pcb_l+10,(pcb_w-5), conn_thickness+pcb_thickness]);
    }
}

module lid(thickness) {
    difference() {
      translate([-size_x/2, -size_y/2, 0]) {
        cube([size_x, size_y, thickness]);
      }
     
      translate([35, 9, thickness]) {
         rotate([0,0,-90]) gy906();
      }
      translate([35, -9, thickness]) {
        rotate([0,0,0]) vlx53L1x(thickness);
      }
      translate([-10, 0, thickness]) {
        heltec_v4();
      }
    }
}

module screw_hole(height) {
    cylinder(height, r=screw_r,  $fn=50, center=false);
    // Cap
    translate([0,0,-1.5]) cylinder(3, r=3,  $fn=50, center=false);
}
module screw_holes(wall) {
  height=10;
  translate([-size_x/2+wall, -size_y/2+wall, 0])
    screw_hole(height);
  translate([size_x/2-wall, -size_y/2+wall, 0])
    screw_hole(height);
  translate([-size_x/2+wall, size_y/2-wall, 0])
    screw_hole(height);
  translate([size_x/2-wall, size_y/2-wall, 0])
    screw_hole(height);
}

// Render lid
/*translate([0, -30, 0]) {
  difference() {
    lid(8);
    translate([0,0, 5]) {
        scale([0.98, 0.98, 1]) box(box_h, box_wall);
        box(box_h, box_wall);
    }
    screw_holes(box_wall);
  }
}*/

// Render case
translate([0, 30, 0]) {
  difference() {
    box(box_h, box_wall);
    
    translate([0,0,-3])
    screw_holes(box_wall);
    
    // Cable gland
    translate([size_x/2,0, box_h/2])
    rotate([0,90,0])
    cylinder(15, 6.5, 6.5, center=true);
  }
}

//heltec_v4();

//vlx53L1x(8);
