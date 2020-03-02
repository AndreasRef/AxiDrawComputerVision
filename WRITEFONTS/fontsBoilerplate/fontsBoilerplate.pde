import geomerative.*;
RFont font;
String myText = "Type";

String fontNames[] = {"1CamBam_Stick_9.ttf", "Akkurat-Light.ttf"}; //Only ttf's work...

int segmentLength = 25;

void setup() {
  size(640,480);  

  RG.init(this);
  font = new RFont(fontNames[0], 300, RFont.LEFT);

  RCommand.setSegmentLength (segmentLength);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
}


void draw() {
  background(255);
  
  if (myText.length() > 0) {
    // get the points on font outline
    RGroup grp;
    grp = font.toGroup(myText);
    grp = grp.toPolygonGroup();
    RPoint[] pnts = grp.getPoints();
    
    //How do figure out when to lift the Axidraw arm? 
    translate(20, 220);
    stroke(0,22,0);
    fill(255,0,0);
    drawUsingLines(pnts);
  }
}

void drawUsingLines(RPoint[] pnts) {
  
  beginShape();
  
    for (int i = 0; i < pnts.length-1; i++ ) {
      if(dist(pnts[i].x, pnts[i].y, pnts[i+1].x, pnts[i+1].y) > segmentLength+1) { //Is this the right way to do it?
        endShape();
        
        //text(i, pnts[i].x, pnts[i].y);
        beginShape();
        
      } else {
        
        vertex(pnts[i].x, pnts[i].y);   
        //text(i, pnts[i].x, pnts[i].y);     
      }
  }
  noFill();
  endShape();
}
