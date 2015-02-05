class Vehicle2c extends Vehicle {
  int F = 200, A = 360, DISPARITY = 45;
  float left, right;
  
  Vehicle2c(String filename, int w, int l) {
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
    // vehicle 2c runs towards the light
    float vl = (l+r)*F, vr = (l+r)*F;
    
    // change in orientation over time
    float dt = 1.0/RATE;
    float da = (vr-vl)/(2*w);
    
    // add 'Brownian' motion
    da += radians(random(A)-A/2);
        
    // overall velocity is average of the 2 wheels
    float s = (vr+vl)/2;
    
    angle = (angle + da*dt) % TAU;
    
    // change in position over time
    float dx = s*cos(-angle);
    float dy = s*sin(-angle);
    addPosition(dx*dt,dy*dt);
  }
  
}
