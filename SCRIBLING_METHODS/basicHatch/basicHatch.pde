float rw= 200;
float rh= 200;
float rx= 100;
float ry= 100;
int nbLines = 15;
float x1 = rx;
float y1 = ry;
float x2 = rx+rw;
float y2 = ry+rh;
float x3 = rx+rw;
float y3 = ry;
float x4 = rx;
float y4 = ry+rh;

float xa, ya, xb, yb;

void setup() {
  size(500, 400);
}

void draw() {
  background(255);
  draw_rect();
}

void draw_rect() {
  stroke(0, 0, 200);
  fill(255);
  rect(rx, ry, rw, rh);
  
  for (int i=0; i<nbLines; i++) {
    stroke(0, 200, 0); 
    xa = map(i, 0, nbLines, x1, x3);
    ya = map(i, 0, nbLines, y1, y3);
    xb = map(i, 0, nbLines, x2, x3);
    yb = map(i, 0, nbLines, y2, y3);
    line(xa, ya, xb, yb);
    
    xa = map(i, 0, nbLines, x1, x4);
    ya = map(i, 0, nbLines, y1, y4);
    xb = map(i, 0, nbLines, x2, x4);
    yb = map(i, 0, nbLines, y2, y4);
    line(xa, ya, xb, yb);
    
    
    stroke(0, 200, 200);
    xa = map(i, 0, nbLines, x3, x2);
    ya = map(i, 0, nbLines, y3, y2);
    xb = map(i, 0, nbLines, x4, x2);
    yb = map(i, 0, nbLines, y4, y2);
    line(xa, ya, xb, yb);
    
    xa = map(i, 0, nbLines, x3, x1);
    ya = map(i, 0, nbLines, y3, y1);
    xb = map(i, 0, nbLines, x4, x1);
    yb = map(i, 0, nbLines, y4, y1);
    line(xa, ya, xb, yb);
  }
}

void mousePressed() {
  randomize();
}

void randomize() {
  rw= random(width);
  rh= random(height);
  rx= random(width-rw);
  ry= random(height-rh);
  nbLines = (int) random(5, 10);
  x1 = rx;
  y1 = ry;
  x2 = rx+rw;
  y2 = ry+rh;
  x3 = rx+rw;
  y3 = ry;
  x4 = rx;
  y4 = ry+rh;
}
