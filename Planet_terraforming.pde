float minDist = 10;
float maxDist = 20;
float digAmount = 25;

boolean showVertices = true;

int vertexCount = 20;
int radius = 100;

Planet p;

boolean mouseDown = false;
boolean dig = true;

void setup() {
  size(750, 750);
  
  p = new Planet(radius, vertexCount);
}

void draw() {
  if(mouseDown) {
    p.dig(new PVector(mouseX - width / 2, mouseY - height / 2), digAmount);
  }
  p.round(0, 1);
  
  background(0);
  p.display();
  
  // Index check ----------------------------------------- remove later
  for(int i = 0; i < p.vertices.size(); i++) {
    if(p.vertices.get(i).i != i) println(1);
  }
}

void mousePressed() {
  mouseDown = true;
}

void mouseReleased() {
  mouseDown = false;
}

void keyPressed() {
  if(key == 'r')
    p = new Planet(radius, vertexCount);
  if(key == 'p')
    p.printVertexMap();
  if(key == 'v')
    showVertices = !showVertices;
}
