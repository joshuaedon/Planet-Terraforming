class Vertex {
  int i;
  float x;
  float y;
  boolean removed;
  
  Vertex(int i, float x, float y) {
    this.i = i;
    this.x = x;
    this.y = y;
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
