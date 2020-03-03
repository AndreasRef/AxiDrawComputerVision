/*To do: 
 What if the point is just a single one? That needs to be drawn as well... I think it gets drawn on paper, even though AxiDraw screen simulation doesn't show it...
 
 */

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
boolean sendToAxidraw = true;

RFont font;
String myText = "Hej verden, What if the point is just a single one? That needs to be drawn as well... I think it gets drawn on paper, even though AxiDraw screen simulation doesn't show it... Make line breaks if text goes beyond line...";
String fontNames[] = {"1CamBam_Stick_5.ttf", "Akkurat-Light.ttf"}; //Only ttf's work...
int fontSize = 50;
int segmentLength = round(fontSize/8); //Small segmentLenghts gives speed at the cost of accurracy 

PVector translateVec = new PVector(20, 120);



void setup() {
  size(640, 480);  
  surface.setLocation(0, 100);

  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 12000);

  RG.init(this);
  font = new RFont(fontNames[0], fontSize, RFont.LEFT);

  RCommand.setSegmentLength (segmentLength);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH); //tends to overlap - okay with CamBam_Stick 9
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP); //better for long segments, but issues when sending...
  //RCommand.setSegmentator(RCommand.ADAPTATIVE); //could work as well, but ignores segmentLenght? Best for CamBam_Stick 5+8?

  String empty = " ";

  background(255);
  if (myText.length() > 0) {
    // get the points on font outline

    for (int i = 0; i<myText.length()-1; i++) {

      if ((str(myText.charAt(i)).equals(empty))) {
        //Whitespace
        if (translateVec.x > 0.6*width) {
          translateVec.set(20, translateVec.y+fontSize);
        } else {
          translateVec.add(fontSize/3,0);
        }
      } else {

        RGroup grp;
        grp = font.toGroup(str(myText.charAt(i)));
        grp = grp.toPolygonGroup();
        RPoint[] pnts = grp.getPoints();

        stroke(0, 22, 0);
        drawFonts(pnts, translateVec);
      }
    }
  }
}

void draw() {
}

void keyPressed() {
  sendToAxidraw = true;
}


void mousePressed() {
  //myText = str(random(10));
}

void drawFonts(RPoint[] pnts, PVector tVec) {
  //fill(255,0,0);
  strokeWeight(2);

  float recordX = 0;

  List<PVector> vecs = new ArrayList<PVector>();
  for (int i = 0; i < pnts.length-1; i+=1 ) {

    if (pnts[i].x > recordX) recordX = pnts[i].x;

    if (dist(pnts[i].x, pnts[i].y, pnts[i+1].x, pnts[i+1].y) > segmentLength+1) { //Is this the right way to do it?
      vecs.add(DELIM_VEC);
      //ellipse(pnts[i].x+tVec.x, pnts[i].y+tVec.y, 5, 5);
      //text(i,  pnts[i].x+tVec.x + 5, pnts[i].y+tVec.y);
      point(pnts[i].x + tVec.x, pnts[i].y + tVec.y);
    } else {
      vecs.add(new PVector(pnts[i].x+tVec.x, pnts[i].y+tVec.y));
      //text(i,  pnts[i].x+tVec.x + 5, pnts[i].y+tVec.y);
      point(pnts[i].x + tVec.x, pnts[i].y + tVec.y);
    }
  }
  strokeWeight(1);
  splitListsAndDraw(vecs);

  if (sendToAxidraw) {  
    splitListsAndSendOSC(vecs);
  }
  //sendToAxidraw = false;
  translateVec.add(recordX, 0);
}
