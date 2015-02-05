abstract class Thing {
  PImage img;
  PVector position;
  float angle, TAU = 2*PI;
  int w, l;
  
  Thing(String filename, int w, int l, float x, float y) {
    img = loadImage(filename);
    position = new PVector(x,y);
    angle = random(TAU);
    this.w = w; 
    this.l = l;
  }
    
  float distance(PVector a, PVector b) {
    return sqrt(pow(a.x-b.x,2)+pow(a.y-b.y,2));
  }

  float angleBetweenPoints(PVector a, PVector b) { 
    float dx = b.x - a.x; 
    float dy = b.y - a.y; 
    return atan2(dy, dx); 
  }
  
  void draw() {
    pushMatrix();
    translate(position.x,position.y);
    // rotate the coordinate frame in the opposite direction
    rotate(-angle);
    image(img,0,0,l,w);
    popMatrix();
  }
  
  void trace() {
  }
  
  void solve(PVector v) {
  }
  
  void setPosition(int x, int y) {
    position = new PVector(x,y);
  }
  
  void addPosition(float x, float y) {
    position.add(x,y,0);
  }
  
  void setAngle(float a) {
    angle = a;
  }
  

  
}
