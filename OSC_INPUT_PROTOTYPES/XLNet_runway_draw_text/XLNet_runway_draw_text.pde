//To do: What if the point is just a single one? That needs to be drawn as well...
//I think it gets drawn on paper, even though AxiDraw screen simulation doesn't show it

import geomerative.*;
import oscP5.*;
import netP5.*;
import java.util.List;
import static java.util.Arrays.binarySearch;

//Runway stuff
import controlP5.*;
//create controlP5 instance
ControlP5 cp5;
// import Runway library
import com.runwayml.*;
// reference to runway instance
RunwayHTTP runway;

String textValue = "";
String text_output;
JSONObject data;
JSONObject json_message;
String json_output;

OscP5 oscP5;
NetAddress dest;

final PVector DELIM_VEC = new PVector(0, 0);

float xScaleFactor = 740.0/640.0;
float yScaleFactor = 523.0/360.0;
boolean sendToAxidraw = false;

RFont font;
//String myText = "Hej verden";
String fontNames[] = {"1CamBam_Stick_9.ttf", "Akkurat-Light.ttf"}; //Only ttf's work...
int fontSize = 25;
int segmentLength = round(fontSize/5); //Small segmentLenghts gives speed at the cost of accurracy 

PVector translateVec = new PVector(20, 220);

void setup() {
  size(640,480);  
  background(255);
  surface.setLocation(0,100);
  
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 12000);

  RG.init(this);
  font = new RFont(fontNames[0], fontSize, RFont.LEFT);

  RCommand.setSegmentLength (segmentLength);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH); //tends to overlap - okay with CamBam_Stick 9
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP); //better for long segments, but issues when sending...
  //RCommand.setSegmentator(RCommand.ADAPTATIVE); //could work as well, but ignores segmentLenght? Best for CamBam_Stick 5+8?

  //Runway
  runway = new RunwayHTTP(this);
  runway.setAutoUpdate(false);
  cp5 = new ControlP5(this);
  //definetextField
  cp5.addTextfield("input").setPosition(20,40).setSize(200,40).setFocus(true).setColor(color(0,255,0));
}


void draw() { 
}

//clear the text field after input
void clear() {
  cp5.get(Textfield.class,"textValue").clear();
}

//send the text from ou interface to RunwayML
void input(String theText) {
  //create json object
  json_message = new JSONObject();
  
  //add the text from the textfield and seed
  json_message.setString("input_prompt", theText);
  json_message.setInt("length", 20); //int 20-500
  json_message.setFloat("temperature", 0.99); //float 0-3
  json_message.setFloat("top_p", 0.9); //float 0-1
 
  print(json_message);
  json_output = json_message.toString();

  //send the message to RunwayML
  runway.query(json_output);
}

// this is called when new Runway data is available
void runwayDataEvent(JSONObject runwayData){
  // point the sketch data to the Runway incoming data 
  data = runwayData;
  //get the value of the "text" key
  text_output = data.getString("generated_text");
  
  stringToFont(text_output);
}

void stringToFont(String myText) {
  if (myText.length() > 0) {
    // get the points on font outline
    RGroup grp;
    grp = font.toGroup(myText);
    grp = grp.toPolygonGroup();
    RPoint[] pnts = grp.getPoints();
    
    stroke(0,22,0);
    sendToAxidraw = true;
    drawFonts(pnts, translateVec);    
  }
}

void drawFonts(RPoint[] pnts, PVector tVec) {
  background(255);
  //fill(255,0,0);
  strokeWeight(2);
  fill(0);
  List<PVector> vecs = new ArrayList<PVector>();
    for (int i = 0; i < pnts.length-1; i+=1 ) {
      if(dist(pnts[i].x, pnts[i].y, pnts[i+1].x, pnts[i+1].y) > segmentLength+1) { //Is this the right way to do it?
        vecs.add(DELIM_VEC);
        //ellipse(pnts[i].x+tVec.x, pnts[i].y+tVec.y, 5, 5);
        //text(i,  pnts[i].x+tVec.x + 5, pnts[i].y+tVec.y);
        //point(pnts[i].x + tVec.x, pnts[i].y + tVec.y);
      } else {
        vecs.add(new PVector(pnts[i].x+tVec.x, pnts[i].y+tVec.y));
        //text(i,  pnts[i].x+tVec.x + 5, pnts[i].y+tVec.y);
        //point(pnts[i].x + tVec.x, pnts[i].y + tVec.y);
      }
  }
  strokeWeight(1);
  splitListsAndDraw(vecs);
  
  if (sendToAxidraw) {  
    splitListsAndSendOSC(vecs); 
  }
  sendToAxidraw = false;
}
