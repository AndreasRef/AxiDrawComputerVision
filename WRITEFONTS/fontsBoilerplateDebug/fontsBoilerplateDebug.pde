import geomerative.*;
RFont font;
String myText = "help";

void setup() {
  size(640, 480);  
  RG.init(this);
  font = new RFont("Eng_VandLine.ttf", 250, RFont.LEFT);
  RCommand.setSegmentLength(20);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
}


void draw() {
  background(255);
  RGroup grp;
  grp = font.toGroup(myText);
  grp = grp.toPolygonGroup();
  RPoint[] pnts = grp.getPoints();

  translate(20, 320);
  drawUsingLines(pnts);
}

void drawUsingLines(RPoint[] pnts) {
  fill(255, 0, 0);
  beginShape();
  for (int i = 0; i < pnts.length-1; i++ ) {    
    vertex(pnts[i].x, pnts[i].y);   
    text(i, pnts[i].x, pnts[i].y);
  }
  noFill();
  endShape();
}
