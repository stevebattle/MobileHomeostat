class Vehicle extends Thing {
  int PATH_LENGTH=1000;
  int MARGIN = 50;

  int pathIndex;
  PVector[] path = new PVector[PATH_LENGTH];
  color pathColour = 0;
  boolean borders = true;
  
  Vehicle(String filename, int w, int l) {
    super(filename, w, l, random(width), random(height));    
  }
  
  void clearPath() {
    path = new PVector[PATH_LENGTH];
    setPathColour(0);
  }
  
  void setPathColour(color c) {
    pathColour = c;
  }
  
  color getPathColour() {
    return pathColour;
  }
  
  void trace() {
    // add current position to path
    path[pathIndex] = new PVector(position.x,position.y);
    pathIndex = (pathIndex+1)%PATH_LENGTH;
    
    for (int i=0; i<PATH_LENGTH-1; i++) {     
      PVector p1 = path[(pathIndex+i)%PATH_LENGTH];
      stroke(pathColour); fill(pathColour);
      if (p1!=null) ellipse(p1.x,p1.y,2,2);
    }
  }
  
  void borders() {
    // keep the vehicle on-screen
    if (borders && (position.x+MARGIN<0 || position.x-MARGIN>width || position.y+MARGIN<0 || position.y-MARGIN>height)) {
      clearPath();
      position.x = (position.x + 3*MARGIN +width) % (width + 2*MARGIN) -MARGIN;
      position.y = (position.y + 3*MARGIN +height) % (height + 2*MARGIN) -MARGIN;
    }
  }
  
  void event(int x, int y) {
    clearPath();
    setPosition(x,y);
  }

}
