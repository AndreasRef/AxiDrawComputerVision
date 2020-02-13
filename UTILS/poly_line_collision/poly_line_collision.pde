float x1 = 0;    // line position (set by mouse)
float y1 = 0;
float x2 = 100;   // fixed end
float y2 = 100;

// array of PVectors, one for each vertex in the polygon
PVector[] vertices = new PVector[5];

void setup() {
  size(600, 400);
  noCursor();

  strokeWeight(5);  // make the line easier to see
  
  vertices[0] = new PVector(100,100);
  vertices[1] = new PVector(200,100);
  vertices[2] = new PVector(100,200);
  vertices[3] = new PVector(10,200);
  vertices[4] = new PVector(150,150);
  
}


void draw() {
  background(255);

  // update line to mouse coordinates
  x1 = mouseX;
  y1 = mouseY;

  // check for collision
  // if hit, change fill color
  boolean hit = polyLine(vertices, x1, y1, x2, y2);
  if (hit) fill(255, 150, 0);
  else fill(0, 150, 255);

  // draw the polygon using beginShape()
  noStroke();
  beginShape();
  for (PVector v : vertices) {
    vertex(v.x, v.y);
  }
  endShape(CLOSE);

  // draw line
  stroke(0, 150);
  line(x1, y1, x2, y2);
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
  if (uA >= 0 && uA <= 2 && uB >= 0 && uB <= 1) {
    return true;
  }
  return false;
}
