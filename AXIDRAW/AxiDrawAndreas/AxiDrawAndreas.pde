PVector[] vectors = new PVector[3];

void setup() {
  size(800, 631);
  setupAxi();
  
  moveTo(10, 10);
  penDown();
  lineTo(50,10);
  penUp();
  //moveTo(0, 0);
  
  vectors[0] = new PVector(100, 100);
  vectors[1] = new PVector(150, 100);
  vectors[2] = new PVector(150, 150);
  
  drawLinesFromArrayOfVecs(vectors);
  
}

void draw() {
  drawAxi(); 
  //if (frameCount % 20 == 0) drawSimpleRect(int(random(500)), int(random(500)), 20, 20);
  
  
}


void mousePressed() { 
  if ((mouseX >= MousePaperLeft) && (mouseX <= MousePaperRight) && (mouseY >= MousePaperTop) && (mouseY <= MousePaperBottom)) { 
    drawSimpleRect(mouseX-MousePaperLeft, mouseY-MousePaperTop, 20, 20);
  }
  checkButtons();  
}

void drawSimpleRect(int x, int y, int w, int h) {
    moveTo(x, y);
    penDown();
    lineTo(x+w, y);
    lineTo(x+w, y+h);
    lineTo(x, y+h);
    lineTo(x, y);
    penUp();
}


//Pseudo-coding a bit here...
void drawLinesFromArrayOfVecs(PVector[] vecs) {
  
  moveTo(vecs[0].x, vecs[0].y);
  penDown();
  for (int i = 1; i<vecs.length; i++) {
    lineTo(vecs[i].x, vecs[i].y);
  }
  penUp();
}
