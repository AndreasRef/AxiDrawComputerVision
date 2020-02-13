import geomerative.*;

RFont font;
String textTyped = "Type ...!";

void setup() {
  size(1324,350);  
  // make window resizable
  surface.setResizable(true); 
  smooth();

  // allways initialize the library in setup
  RG.init(this);
  font = new RFont("1CamBam_Stick_5.ttf", 200, RFont.LEFT);

  // get the points on the curve's shape
  // set style and segment resultion

  //RCommand.setSegmentStep(11);
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  RCommand.setSegmentLength (1);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  //RCommand.setSegmentAngle(random(0,HALF_PI));
  //RCommand.setSegmentator(RCommand.ADAPTATIVE);
}


void draw() {
  background(255);
  // margin border
  translate(20,220);

  if (textTyped.length() > 0) {
    // get the points on font outline
    RGroup grp;
    grp = font.toGroup(textTyped);
    grp = grp.toPolygonGroup();
    RPoint[] pnts = grp.getPoints();
    
    //How do figure out when to lift the Axidraw arm? 

    stroke(0);    
    drawUsingPoints(pnts);
    
    translate(20, 20);
    stroke(0,255,0);
    drawUsingLines(pnts);
  }
}

void drawUsingLines(RPoint[] pnts) {
  beginShape();
    for (int i = 0; i < pnts.length-1; i++ ) {
      if(dist(pnts[i].x, pnts[i].y, pnts[i+1].x, pnts[i+1].y) > 5) { 
        endShape();
        beginShape();        
      } else {
        vertex(pnts[i].x, pnts[i].y);   
      }
  }
  endShape();
}

void drawUsingPoints(RPoint[] pnts) {
    for (int i = 0; i < pnts.length; i++ ) {
      point(pnts[i].x, pnts[i].y);   
  }
}
