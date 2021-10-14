float vertexGroupSize = 50;

class Planet {
  ArrayList<Vertex> vertices;
  ArrayList<ArrayList<ArrayList<Vertex>>> vertexMap;
  
  PVector com;
  
  Planet(float radius, int vertexCount) {
    vertices = new ArrayList<Vertex>();
    
    vertexMap = new ArrayList<ArrayList<ArrayList<Vertex>>>();   
    
    
    for(int i = 0; i < vertexCount; i++) {
      Vertex vertex = new Vertex(i, radius*cos(i*2*PI/vertexCount), radius*sin(i*2*PI/vertexCount));
      
      vertices.add(vertex);
      addVertexToMap(vertex);
    }
    
    setCoM();
  }
  
  void printVertexMap() {
    for(int i = 0; i < vertexMap.size(); i++) {
      for(int j = 0; j < vertexMap.get(i).size(); j++) {
        print(vertexMap.get(i).get(j).size() + ", ");
      }
      println();
    }
  }
  
  // Adds a vertex to the vertexMap and increases the size of vertexMap if needed
  void addVertexToMap(Vertex vertex) {
    int indexX = getMappedIndex(vertex.x);
    int indexY = getMappedIndex(vertex.y);
    
    while(vertexMap.size() <= indexX)
      vertexMap.add(new ArrayList<ArrayList<Vertex>>());
    while(vertexMap.get(indexX).size() <= indexY)
      vertexMap.get(indexX).add(new ArrayList<Vertex>());
    
    vertexMap.get(indexX).get(indexY).add(vertex);
  }
  
  // Removes a vertex from vertices and vertexMap
  void removeVertex(Vertex vertex) {
    int indexX = getMappedIndex(vertex.x);
    int indexY = getMappedIndex(vertex.y);
    
    ArrayList<Vertex> vertexGroup = vertexMap.get(indexX).get(indexY);
    for(int j = 0; j < vertexGroup.size(); j++) {
      if(vertexGroup.get(j) == vertex) {
        vertexGroup.remove(j);
        break;
      }
    }
    
    vertices.remove(vertex.i);
    for(int i = vertex.i; i < vertices.size(); i++)
      vertices.get(i).decreaseI(1);
      
    vertex.removed = true;
  }
  
  // Moves a vertex's position, moving it in vertexMap if needed
  void moveVertex(Vertex vertex, PVector displacement) {
    int indexX = getMappedIndex(vertex.x);
    int indexY = getMappedIndex(vertex.y);
    
    ArrayList<Vertex> vertexGroup = vertexMap.get(indexX).get(indexY);
    int j = 0;
    while(vertexGroup.get(j) != vertex) {
      j++;
    }
    
    vertex.add(displacement);
    
    int newIndexX = getMappedIndex(vertex.x);
    int newIndexY = getMappedIndex(vertex.y);
    
    if(indexX != newIndexX || indexY != newIndexY) {
      vertexGroup.remove(j);
      addVertexToMap(vertex);
    }
  }
  
  // Gets the coordinate of a vertex in vertexMap
  int getMappedIndex(float x) {
    int mappedCoord = floor(x / vertexGroupSize);
    int index = mappedCoord * 2;
    if(index < 0)
      index = -(index + 1);
    return index;
  }
  
  // Move vertices and adjust
  void dig(PVector mousePos, float amount) {
    ArrayList<Vertex> movedVertices = new ArrayList<Vertex>();
    
    for(int i = 0; i < vertices.size(); i++) {
      Vertex vertex = vertices.get(i);
      
      PVector dist = vertex.getVector().sub(mousePos);
      if(dist.magSq() < amount * amount) {
        dist.mult((amount - dist.mag()) / dist.mag());
        moveVertex(vertex, dist);
        
        Vertex prevV = vertices.get((i > 0) ? i - 1 : vertices.size() - 1);
        Vertex nextV = vertices.get((i + 1) % vertices.size());
        if(checkAddVs(prevV, vertex))
          i++;
        if(checkAddVs(vertex, nextV))
          i++;
          
        movedVertices.add(vertex);
      }
    }
    
    // Remove vertices
    for(Vertex movedVertex : movedVertices) {
      if(!movedVertex.removed)
        checkRemoveVs(movedVertex);
    }
    
    setCoM();
  }
  
  // Adds new vertices if the space in between current ones has grown past a certain distance 
  boolean checkAddVs(Vertex v1, Vertex v2) {
    if(sqDist(v1, v2) > maxDist * maxDist) {
      PVector newVPos = v1.getVector().add(v2.getVector().sub(v1.getVector()).div(2));
      Vertex newV = new Vertex(v2.i, newVPos.x, newVPos.y);
      vertices.add(v2.i, newV);
      for(int i = v2.i + 1; i < vertices.size(); i++)
        vertices.get(i).increaseI(1);
      addVertexToMap(newV);
      return true;
    }
    return false;
  }
  
  void checkRemoveVs(Vertex movedVertex) {
    int newIndexX = getMappedIndex(movedVertex.x);
    int newIndexY = getMappedIndex(movedVertex.y);
    
    for(int x = max(0, newIndexX - 2); x <= min(vertexMap.size() - 1, newIndexX + 2); x++) {
      // Only for x two/zero away from newIndexX
      if((x + newIndexX) % 2 != 0)
        continue;
      for(int y = max(0, newIndexY - 2); y <= min(vertexMap.get(x).size() - 1, newIndexY + 2); y++) {
        // Only for y two/zero away from newIndexY
        if((y + newIndexY) % 2 != 0)
          continue;
        for(int i = 0; i < vertexMap.get(x).get(y).size(); i++) {
          // If a vertex has been found which is in range to the moved vertex, do not try to find more
          if(checkRemoveVsPair(movedVertex, vertexMap.get(x).get(y).get(i)))
            return;
        }
      }
    }
  }
  
  // Returns if vertices were removed
  boolean checkRemoveVsPair(Vertex v1, Vertex v2) {
    if(v1 != v2 && sqDist(v1, v2) < minDist * minDist) {
      int lowI = min(v1.i, v2.i);
      int highI = max(v1.i, v2.i);
      
      if(highI - lowI < vertices.size() - highI + lowI) {
        for(int i = highI; i > lowI; i--) { // Inefficient as increments all vertices infront by one many times (and below)
          removeVertex(vertices.get(i));
          //println("removed " + i);
        }
      } else {
        for(int i = vertices.size() - 1; i > highI; i--) {
          removeVertex(vertices.get(i));
          //println("removed " + i);
        }
        for(int i = lowI - 1; i >= 0; i--) {
          removeVertex(vertices.get(i));
          //println("removed " + i);
        }
      }
      return true;
    }
    return false;
  }
  
  void setCoM() {
    float x = 0;
    float y = 0;
    float signedArea = 0;
    
    for(int i = 0; i < vertices.size(); i++) {
      Vertex v1 = vertices.get(i);
      Vertex v2 = vertices.get((i < vertices.size() - 1) ? i+1 : 0);
      
      float a = v1.x * v2.y - v2.x * v1.y;
      signedArea += a;
      
      x += (v1.x + v2.x) * a;
      y += (v1.y + v2.y) * a;
    }
    
    signedArea /= 2;
    
    //println(signedArea);
    
    x /= 6 * signedArea;
    y /= 6 * signedArea;
    
    com = new PVector(x, y);
  }
  
  void round(float threshold, float amount) {
    ArrayList<Vertex> movedVertices = new ArrayList<Vertex>();
    
    PVector[] dists = new PVector[vertices.size()];
    
    for(int i = 0; i < vertices.size(); i++) {
      Vertex vertex = vertices.get(i);
      
      PVector dist = com.copy().sub(vertex.getVector());
      dists[i] = dist;
    }
    
    for(int i = 0; i < vertices.size(); i++) {
      Vertex vertex = vertices.get(i);
      
      float prevDist = dists[(i > 0) ? i - 1 : vertices.size() - 1].mag();
      float nextDist = dists[(i + 1) % vertices.size()].mag();
      float diff = -((prevDist + nextDist) / 2 - dists[i].mag());
      
      if(diff > threshold) {
        PVector displacement = dists[i].copy().setMag(diff * amount);
        moveVertex(vertex, displacement);
        
        //Vertex prevV = vertices.get((i > 0) ? i - 1 : vertices.size() - 1);
        //Vertex nextV = vertices.get((i + 1) % vertices.size());
        //if(checkAddVs(prevV, vertex))
        //  i++;
        //if(checkAddVs(vertex, nextV))
        //  i++;
          
        movedVertices.add(vertex);
      }
    }
    
    // Remove vertices
    for(Vertex movedVertex : movedVertices) {
      if(!movedVertex.removed)
        checkRemoveVs(movedVertex);
    }
    
    //setCoM();
  }
  
  void display() {
    fill(100, 100, 50);
    beginShape();
    for(Vertex v : vertices)
      vertex(width / 2 + v.x, height / 2 + v.y);
    endShape();
    
    if(showVertices) {
      fill(255);
      for(Vertex v : vertices)
        ellipse(width / 2 + v.x, height / 2 + v.y, 5, 5);
      // CoM
      fill(255, 0, 0);
      ellipse(width / 2 + com.x, height / 2 + com.y, 7.5, 7.5);
    }
  }
  
  float sqDist(Vertex a, Vertex b) {
    return (a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y); 
  }
}
