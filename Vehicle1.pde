class Vehicle1 extends Vehicle {
  int F = 100, A=360;
  
  Vehicle1(String filename, int w, int l) {
    super(filename, w, l);    
  }
  
  /* differential steering based on http://rossum.sourceforge.net/papers/DiffSteer/ */
  
  void solve(PVector src) {
    // calculate inverse distance from light source
    float d = (width/2)/distance(position,src);
    
    // motor velocity proportional to input
    // vehicle 1 is activated by light
    float s = d*F;
    
    // change in orientation over time
    float dt = 1.0/RATE;
    float da = radians(random(A)-A/2);
    
    angle = (angle + da*dt) % TAU;
    
    // change in position over time
    float dx = s*cos(-angle);
    float dy = s*sin(-angle);
    addPosition(dx*dt,dy*dt);
  }
  
}
