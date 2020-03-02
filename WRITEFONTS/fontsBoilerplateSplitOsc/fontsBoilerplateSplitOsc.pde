import geomerative.*;
import oscP5.*;
import netP5.*;
import java.util.List;
import static java.util.Arrays.binarySearch;

OscP5 oscP5;
NetAddress dest;
final PVector DELIM_VEC = new PVector(0, 0);

float xScaleFactor = 740.0/640.0;
float yScaleFactor = 523.0/360.0;


RFont font;
String myText = "Type";

String fontNames[] = {"1CamBam_Stick_5.ttf", "Akkurat-Light.ttf"}; //Only ttf's work...

int segmentLength = 5;

boolean sendToAxidraw = false;

void setup() {
  size(640,480);  
  
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 12000);

  RG.init(this);
  font = new RFont(fontNames[0], 50, RFont.LEFT);

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
    //translate(20, 220);
    stroke(0,22,0);
    drawFonts(pnts);
    
  }
}

void keyPressed() {
  sendToAxidraw = true;
}

void drawFonts(RPoint[] pnts) {
  List<PVector> vecs = new ArrayList<PVector>();
    for (int i = 0; i < pnts.length-1; i++ ) {
      if(dist(pnts[i].x, pnts[i].y, pnts[i+1].x, pnts[i+1].y) > segmentLength+1) { //Is this the right way to do it?
        vecs.add(DELIM_VEC);
        ellipse(pnts[i].x+20, pnts[i].y+220, 5, 5);
      } else {
        vecs.add(new PVector(pnts[i].x+20, pnts[i].y+220));
        ellipse(pnts[i].x+20, pnts[i].y+220, 5, 5);
      }
  }
  
  splitListsAndDraw(vecs);
  
  //send to AxiDraw
  if (sendToAxidraw) {  
    splitListsAndSendOSC(vecs); 
  }
  sendToAxidraw = false;
  vecs.clear(); //is this needed?
}
