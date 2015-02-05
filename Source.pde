/*** light source ***/

class Source extends Thing {
  float F = 0.01;
  
  Source(String filename, int d, float x, float y) {
    super(filename, d, d, x, y);
  }
    
  void solve(PVector v) {
    angle = (angle + F) % TAU;
  }
  
}
