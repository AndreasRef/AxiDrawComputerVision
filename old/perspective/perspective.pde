//To do: Do not only check if point is inside original polygon, but also if the line at some point is inside...
PVector vanishingPoint = new PVector (300, 50);
boolean transparencyMode = false;
PVector[] vectors = new PVector[5];
PVector[] moreVectors = new PVector[3];

void setup() {
  size(600, 400);
  fill(0);
  
  vectors[0] = new PVector(100, 200);
  vectors[1] = new PVector(200, 220);
  vectors[2] = new PVector(200, 300);
  vectors[3] = new PVector(100, 300);
  vectors[4] = new PVector(50, 250);
  
  moreVectors[0] = new PVector(300+100, 200);
  moreVectors[1] = new PVector(300+200, 220);
  moreVectors[2] = new PVector(300+200, 300);
}

void draw() {
  background(255);
  
  //drawInitialShape(vectors);
  //drawPerspective(vectors);
  
  drawInitialShape(moreVectors);
  drawPerspective(moreVectors);
  
  vanishingPoint.set(mouseX, mouseY);
  ellipse(vanishingPoint.x, vanishingPoint.y, 5, 5);  
  
  text("transparency: " + str(transparencyMode), 10, 15);
}

void mousePressed() {
  transparencyMode = !transparencyMode;
}

void drawInitialShape(PVector[] vecs) {
  for (int i = 0; i<vecs.length; i++) {
    if (i<vecs.length-1)line(vecs[i].x, vecs[i].y, vecs[i+1].x, vecs[i+1].y);
    if (i==vecs.length-1) line(vecs[i].x, vecs[i].y, vecs[0].x, vecs[0].y); //Close it
  }
}

void drawPerspective (PVector[] vecs) {
  PVector[] target = new PVector[vecs.length];
  for (int i = 0; i<vecs.length; i++) {
    target[i] = vecs[i].copy();
    target[i].lerp(vanishingPoint, 0.2);
    //if (outsidePolyCheck(target[i], vecs)) line(vecs[i].x, vecs[i].y, target[i].x, target[i].y);
    if(!polyLine(vecs, vecs[i].x, vecs[i].y, target[i].x, target[i].y)) line(vecs[i].x, vecs[i].y, target[i].x, target[i].y);
  }
  //connectPerspectiveLines(vecs, target);
}

void connectPerspectiveLines(PVector[] vecs, PVector[] target) {
  for (int i = 0; i<target.length; i++) {
    //if (i<target.length-1 && outsidePolyCheck(target[i+1], vecs) && outsidePolyCheck(target[i], vecs)) line(target[i].x, target[i].y, target[i+1].x, target[i+1].y);
    //if (i==target.length-1 && outsidePolyCheck(target[0], vecs) && outsidePolyCheck(target[i], vecs)) line(target[i].x, target[i].y, target[0].x, target[0].y); //close it
    if (i<target.length-1) line(target[i].x, target[i].y, target[i+1].x, target[i+1].y);
    if (i==target.length-1) line(target[i].x, target[i].y, target[0].x, target[0].y); //close it
  }  
}

// POLYGON/LINE
boolean polyLine(PVector[] vertices, float x1, float y1, float x2, float y2) {

  // go through each of the vertices, plus the next
  // vertex in the list
  int next = 0;
  for (int current=0; current<vertices.length; current++) {

    // get next vertex in list
    // if we've hit the end, wrap around to 0
    next = current+1;
    if (next == vertices.length) next = 0;

    // get the PVectors at our current position
    // extract X/Y coordinates from each
    float x3 = vertices[current].x;
    float y3 = vertices[current].y;
    float x4 = vertices[next].x;
    float y4 = vertices[next].y;

    // do a Line/Line comparison
    // if true, return 'true' immediately and
    // stop testing (faster)
    boolean hit = lineLine(x1, y1, x2, y2, x3, y3, x4, y4);
    if (hit) {
      return true;
    }
  }

  // never got a hit
  return false;
}


// LINE/LINE
boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

  // calculate the direction of the lines
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    return true;
  }
  return false;
}


boolean outsidePolyCheck(PVector v, PVector [] p) {
  if (transparencyMode) return true; //Skip all the checks of we want to draw transparent shapes
  
  float a = 0;
  for (int i =0; i<p.length-1; ++i) {
    PVector v1 = p[i].copy();
    PVector v2 = p[i+1].copy();
    a += vAtan2cent180(v, v1, v2);
  }
  PVector v1 = p[p.length-1].copy();
  PVector v2 = p[0].copy();
  a += vAtan2cent180(v, v1, v2);

  if (abs(abs(a) - TWO_PI) < 0.001) return false;
  else return true;
}

float vAtan2cent180(PVector cent, PVector v2, PVector v1) {
  PVector vA = v1.copy();
  PVector vB = v2.copy();
  vA.sub(cent);
  vB.sub(cent);
  vB.mult(-1);
  float ang = atan2(vB.x, vB.y) - atan2(vA.x, vA.y);
  if (ang < 0) ang = TWO_PI + ang;
  ang-=PI;
  return ang;
}
