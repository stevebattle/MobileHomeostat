/* @pjs preload="source.png, vehicle1.png, vehicle2a.png, vehicle2b.png, vehicle2c.png, bg800x800.jpg";
 */

/*
   Braitenberg Vehicles simulation
 
   Copyright 2013 Steve Battle
 
   This work is licensed under a Creative Commons Attribution 3.0 Unported License.
   
   You may obtain a copy of the License at
 
       http://creativecommons.org/licenses/by/3.0
*/

int RATE=25;
int VWIDTH=55, VLENGTH=85, VSIDE=50;

PImage bg;
Thing src;
Vehicle vehicle, v1, v2a, v2b, v2c, v6a, h1;

void setup() {
  size(800,800);
  frameRate(RATE);
  imageMode(CENTER);
  
  // java alternative (generates image)
  //bg = createImage(width, height, RGB);
  //backgroundImage(bg,new PVector(width/2,height/2));
  //bg.save("data/bg800x800.jpg");
  
  // javascript alternative
  bg = loadImage("bg800x800.jpg");
  
  background(bg); 
  
  src = new Source("source.png",VSIDE,width/2,height/2);
  v1  = new Vehicle1("vehicle1.png",30,VLENGTH);
  v2a = new Vehicle2a("vehicle2a.png",VWIDTH,VLENGTH);
  v2b = new Vehicle2b("vehicle2b.png",VWIDTH,VLENGTH);
  v2c = new Vehicle2c("vehicle2c.png",VWIDTH,VLENGTH);
  //h1 = new Homeostat("vehicle6.png",VWIDTH,VLENGTH);
  h1 = new Homeostat("vehicle6.png",VWIDTH,VLENGTH, 
  //    new float[] {-0.5, 0.0, 0.0, -0.5, -0.01, 2.8920174E-4, 0.1, 0.07791245, 0.12929058, 1.0, 1.0}); // circle

  //new float[] {-0.5, 0.0, 0.0, -0.5, -0.08046472, 0.19400847, 0.24734187, 0.12929058, 1.0, 1.0}); nice when it works
    new float[] {-0.5, 0.0, 0.0, -0.5, -0.096187115, 2.8920174E-4, 0.12929058, 0.07791245, 0.12929058, 1.0, 1.0}); // atomic
  //  new float[] {-0.5, 0.0, 0.0, -0.5, -2.8920174E-4, 0.096187115, -0.07791245, -0.12929058, 1.0, 1.0}); // flower
  //  new float[] {-0.5, 0.0, 0.0, -0.5, 0.103542924, 0.062425256, -0.17249525, -0.81386876, 1.0, 1.0});
  //setVehicle(initialise);
  setVehicle("h1");
}

void setVehicle(String v) {
  PVector p=null;
  float a = radians(random(360));
  if (vehicle!=null) {
    p = vehicle.position;
    a = vehicle.angle;
  }
  if (v=="1") vehicle = v1;
  else if (v=="2a") vehicle = v2a;
  else if (v=="2b") vehicle = v2b;
  else if (v=="2c") vehicle = v2c;
  else if (v=="6a") vehicle = v6a;
  else if (v=="h1") vehicle = h1;
  if (p!=null) {
    vehicle.position = p;
    vehicle.angle = a;
  }
}

void backgroundImage(PImage img, PVector v) {
  img.loadPixels();
  float dmax = sqrt(pow(img.width,2)+pow(img.height,2))/2;
  // pythagorean distance: sqrt(dx^2 + dy^2)
  for (int y=0; y<img.height; y++) {
    // dy^2 is constant for this row
    float dy2 = pow(y-v.y,2);
    for (int x=0; x<img.width; x++) {
      float dx2 = pow(x-v.x,2);
      float d = sqrt(dx2+dy2)/dmax;
      float l = 255.0*(1-d);
      img.pixels[x+y*img.width] = color(l,l,l);
    }
  }
  img.updatePixels();
}

void draw() {
  // in processingjs imageMode() applies to the background image
  imageMode(CORNER);
  background(bg);
  imageMode(CENTER);
  
  src.draw();
  src.solve(null);

  if (vehicle!=null) {
    vehicle.trace();
    vehicle.draw();
    vehicle.solve(src.position);
    vehicle.borders();
  }
}

void mouseClicked() {
  vehicle.event(mouseX,mouseY);
}
