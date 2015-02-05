/*
   Mobile Homeostat
 
   Copyright 2014 Steve Battle
 
   This work is licensed under a Creative Commons Attribution 3.0 Unported License.
   
   You may obtain a copy of the License at
 
       http://creativecommons.org/licenses/by/3.0
*/

class Homeostat extends Vehicle {

  int RATE=25;
  int F = 300;
  float G = 0.5;
  int MAX_TRIALS = 20, MAX_RESULTS=100;
  boolean KILL_ROBOT=false; // kill robot when stability is achieved to collect data
  boolean DEMO_CROSSOVER=true; // demonstrate left/right input crossover on click
  int[] results = new int[MAX_RESULTS];
  
  // u units, n inputs, h force on the needle, j ratio of viscosity to inertia, p minimum potential, q maximum potential
  int u, n;
  float[] a, j, x, y, z ;
  float h, p, q;
  boolean[] r, s;
  boolean crossed=false;
  
  float left, right;
  float INTERVAL = 1.0/3.0f; // check relays once every three seconds
  float dt = 1.0f/RATE;
  int stable, trials, result;
  
  // two homeostatic units: left motor, right motor
  // three parameters: left eye, right eye, distance

  int N=2, P=3;
  float[] xo, yo; // unit output
  int COUNT = int(RATE/INTERVAL), count = COUNT;
  
  public void configure(int n, int u) {    
    // weight matrix n rows, u cols
    a = new float[n*u];
    j = new float[u];
    x = new float[n];
    y = new float[n];
    z = new float[n];

    // all weights are under uniselector control by default
    s = new boolean[n*u] ;
    for (int i=0; i<n; i++) {
      for (int k=0; k<u; k++) {
        s[i*u+k] = true ;
      }  
    }
    
    // enable relays, clear triggers
    r = new boolean[u];
    for (int i=0; i<u; i++ ) {
      r[i] = true;
    }
  }
  
  // randomize weights subject to the uniselector enablements
  
  void randomize(float min, float max) {
    for (int i=0; i<n; i++) {
      for (int j=0; j<u; j++) {
        if (s[i*u+j]) {
          a[i*u+j] = random(max - min) +min ;
        }
      }
    }
  }
  
  // client should at least set the weight on the recurrent self-input
  // other weights may be set manually
  // setWeight(row,col,weight)
  
  void setWeight(int i, int j, float w) {
    a[i*u+j] = w ;
    s[i*u+j] = false ;
  }
  
  Homeostat(String filename, int w, int l) {
    super(filename, w, l);
    borders = false;

    n = N+P;
    u = N;
    h = 1f;
    p = 1f;
    q = -1f;
    
    // N+P rows, cols
    configure(n,u);
    
    // eyes project forwards at 90 degrees from each other
    left = radians(45);
    right = -left;
    
    // configure homeostat units N with additional input parameters P
    for (int i=0; i<N; i++) {
      j[i] = 1f;
      setWeight(i,i,-0.5f); // recurrent connection
      setWeight(N+2,i,1); // essential variable
    }
    
    // randomize remaining weights 
    randomize(q,p);     

    // sever links between units
    setWeight(0,1,0);
    setWeight(1,0,0);
  }
  
  Homeostat(String filename, int w, int l, float[] m) {
    this(filename,w,l);
    for (int i=0; i<n*u; i++) {
      a[i] = m[i];
    }
  }
  
  /* multiply l*m (rows,cols) matrix by m*n matrix */

  void multiply(float a[], float b[], float c[], int l, int m, int n) {
    for (int i=0; i<l; i++) {
      for (int j=0; j<n; j++) {
        c[i*n+j] = 0;
        for (int k=0; k<m; k++) {
          c[i*n+j] += a[i*m+k]*b[k*n+j];
        }
      }
    }
  }
 
    // solve for y,z using Euler's method and return y
    
    void solve(float[] p, float dt) {
      for (int i=0; i<u; i++) {      
        float dy = z[i];
        float dz = h*p[i] - j[i]*z[i];  
        // with h=1, j=1 this simplifies to p[i] - z[i]  
        y[i] += dy*dt;
        z[i] += dz*dt;
        
        // velocity becomes zero when the essential variable goes out of bounds
        y[i] = saturation(y[i]);
      }
    }
    
    
    float saturation(float y) {
      return min(p, max(q, y));
    }
 
  /* differential steering based on http://rossum.sourceforge.net/papers/DiffSteer/ */
  
  void solve(PVector src) {
    // calculate angle to light source
    float theta = (TAU - angleBetweenPoints(position,src)) % TAU ;
    
    // cosine distance
    float l = cos(theta-angle-left);
    float r = cos(theta-angle-right);
        
    // calculate distance from light source
    float ds = distance(position,src)/(width/2);
    
    x[N] = crossed?r:l;
    x[N+1] = crossed?l:r;
    x[N+2] = ds>1 ? 1 : 0;

    float[] p = new float[u];
    multiply(x,a,p,1,n,u);
           
    // solve for y
    solve(p,dt);
    for (int i=0; i<N; i++) {
      x[i] = y[i];
    }
        
    // step function at end of trial
    if (count-- == 0) {
      trials++;
      stable++;
      if (step()) {
        stable = 0;
        if (DEMO_CROSSOVER) setPathColour(crossed?color(255,0,0):0);

        // reposition if too far out
        if (ds>1) {
          setPosition(int(random(width)),int(random(height)));
          setAngle(random(TAU));
        }
        clearPath();
      } 
      if (stable==MAX_TRIALS) {
        printWeights();
        if (DEMO_CROSSOVER) setPathColour(color(0,255,0));
        
        if (KILL_ROBOT) {
          if (result<MAX_RESULTS) {
            results[result++] = trials - stable;
          }
          printResults();
          reset();
        }
      } 
      count = COUNT; // restart the count
    }
  
    // motor velocity
    float vl = F*x[0], vr = F*x[1];
    
    float da = (vr-vl)/(2*w);
    
    // overall velocity is average of the 2 wheels
    float v = (vr+vl)/2;
    
    angle = (angle + da*dt) % TAU;
    
    // change in position over time
    float dx = v*cos(-angle);
    float dy = v*sin(-angle);
    addPosition(dx*dt,dy*dt);
  }
  
    // check the inputs to the relay
    // if the needle setting y is outside the bounds [q,p] then the relay 
    boolean step(int k) {
      if (r[k] && (y[k]<=q || y[k]>=p)) {
        for (int i=0; i<n; i++) {
          if (s[i*u+k]) {
            a[i*u+k] = random(p - q) +q; // [-1,+1]
          }
        }
        y[k] = z[k] = 0;
        return true;
      }
      else return false;
    }
  
  boolean step() {
      boolean b = false;
      for (int i=0; i<N; i++) {
         if (step(i)) {
           x[i] = 0;
           b = true;
         }
      }
      return b;
  }
  
  void reset() {
    randomize(q,p);     
    // ensure independence between trials
    setPosition(int(random(width)),int(random(height)));
    setAngle(random(TAU));
    trials = 0;
    stable=0;
    clearPath();
    // clear state variables
    for (int i=0; i<u; i++) {
      y[i] = z[i] = 0f;
    }
    crossed = false;
  }
   
  void event(int px, int py) {
    if (DEMO_CROSSOVER && getPathColour()==color(0,255,0)) {
      crossed = true;
      setPathColour(0);
    }
    else reset();
  }
  
  void printWeights() {
    // print weight matrix
    for (int i=0; i<n*u; i++) {
      print(a[i]);
      print(" ");
    }
    println();
  }
  
  void printResults() {
    println();
    print(result);
    println(" RESULTS:");
    for (int i=0; i<result; i++) {
      println(results[i]);
    }
  }
    
}
