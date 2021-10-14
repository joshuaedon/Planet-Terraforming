class Vertex {
  int i;
  
  float x;
  float y;
  
  PVector normal;
  
  boolean removed;
  
  Vertex(int i, float x, float y) {
    this.i = i;
    this.x = x;
    this.y = y;
    
    this.normal = new PVector(0, 0);
    
    this.removed = false;
  }
  
  void increaseI(int a) {
    i += a;
  }
  
  void decreaseI(int a) {
    i -= a;
  }
  
  void add(PVector v) {
    x = x + v.x;
    y = y + v.y;
  }
  
  PVector getVector() {
    return new PVector(x, y);
  }
}
