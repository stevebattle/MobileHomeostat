class Vehicle2a extends Vehicle {
  int F = 600, DISPARITY = 45;
  float left, right;
  
  Vehicle2a(String filename, int w, int l) {
    super(filename, w, l);    
    left = radians(DISPARITY);
    right = -left;
  }
  
  /* differential steering based on http://rossum.sourceforge.net/papers/DiffSteer/ */
  
  void solve(PVector src) {
    // calculate angle to light source
    float a = (TAU - angleBetweenPoints(position,src)) % TAU ;
    
    // cosine distance shifted into the range [0,1]
    float l = cos(a-angle-left)/2 +0.5;
    float r = cos(a-angle-right)/2 +0.5;
    
    // motor velocity proportional to input
    // vehicle 2b runs away from the light
    float vl = l*F, vr = r*F;
    
    // change in orientation over time
    float dt = 1.0/RATE;
    float da = (vr-vl)/(2*w);
    
    // overall velocity is average of the 2 wheels
    float s = (vr+vl)/2;
    
    angle = (angle + da*dt) % TAU;
    
    // change in position over time
    float dx = s*cos(-angle);
    float dy = s*sin(-angle);
    addPosition(dx*dt,dy*dt);
  }
  
}
