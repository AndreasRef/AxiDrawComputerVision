import oscP5.*;
OscP5 oscP5;
PVector[] vectors = new PVector[3];

void setup() {
  size(800, 631);
  setupAxi();
  oscP5 = new OscP5(this, 12000);

  moveTo(10, 10);
  penDown();
  lineTo(50, 10);
  penUp();
  //moveTo(0, 0);

  vectors[0] = new PVector(100, 100);
  vectors[1] = new PVector(150, 100);
  vectors[2] = new PVector(150, 150);

  //drawLinesFromArrayOfVecs(vectors);
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

//Beginning of OSC setup here - really hacky because of conversion between vectors and ints
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/drawVertex") == true) {

    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
    println("length: " + theOscMessage.arguments().length);
    //int messageLength = theOscMessage.arguments().length;
    int nVectors = theOscMessage.arguments().length/2;
    println("nVectors:  " + nVectors);

    PVector[] myVecs = new PVector[nVectors];
 
     for (int i = 0; i<nVectors; i++) { //Initialize all vectors with (0,0);
       myVecs[i] = new PVector(theOscMessage.get(i*2).intValue(), theOscMessage.get(i*2+1).intValue());
       println(i + ": " + myVecs[i]);
    }
    drawLinesFromArrayOfVecs(myVecs);
  }
}

void drawLinesFromArrayOfVecs(PVector[] vecs) {
  moveTo(vecs[0].x, vecs[0].y);
  penDown();
  for (int i = 1; i<vecs.length; i++) {
    lineTo(vecs[i].x, vecs[i].y);
  }
  penUp();
}
