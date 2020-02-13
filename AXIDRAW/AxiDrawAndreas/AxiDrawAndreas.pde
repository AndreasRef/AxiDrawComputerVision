void setup() {
  size(800, 631);
  setupAxi();
  
  moveTo(10, 10);
  penDown();
  lineTo(50,10);
  penUp();
  //moveTo(0, 0);
  
  drawSimpleRect(100,100,50,50);
}

void draw() {
  drawAxi();
}


void mousePressed() {
  boolean doHighlightRedraw = false;

  //The mouse button was just pressed!  Let's see where the user clicked!
  if ((mouseX >= MousePaperLeft) && (mouseX <= MousePaperRight) && (mouseY >= MousePaperTop) && (mouseY <= MousePaperBottom)) { 
    //GenerateArtwork(mouseX, mouseY, 5 , 10);
    moveTo(mouseX-MousePaperLeft, mouseY-MousePaperTop);
    penDown();
    lineTo(mouseX-MousePaperLeft+50, mouseY-MousePaperTop+50);
    penUp();
    doHighlightRedraw = true;
  }

  if (doHighlightRedraw) {
    redrawLocator();
    redrawHighlight();
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
