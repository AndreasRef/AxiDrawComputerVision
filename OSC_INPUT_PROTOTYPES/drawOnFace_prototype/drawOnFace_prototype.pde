//To do
//Function to calculate outPut coordinates to paper coordinates

import processing.video.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

import oscP5.*;
import netP5.*;
import java.util.List;
import static java.util.Arrays.binarySearch;
import java.awt.*;

OscP5 oscP5;
NetAddress dest;

//List<PVector> vecs = new ArrayList<PVector>();
final PVector DELIM_VEC = new PVector(0,0);
//List<List<PVector>> vecs2d;

Capture video;
OpenCV opencv;
PImage staticImage;
PImage output;
int outputWidth = 640;
int outputHeight = 360;

Contour contour;
ArrayList<PVector> perspectiveVecs = new ArrayList<PVector>();
boolean imageReady;;
Boolean webcamMode = true;

Table table; //Table for storing perspectivePoints

boolean sendToAxidraw = false;

void setup() {
  size(640, 720);
  surface.setLocation(0, 100);
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1", 12000);
  
  loadPerspectiveVecs();
  
  if (webcamMode) {
    String[] cameras = Capture.list();
    video = new Capture(this, 640, 360, cameras[0]);
    video.start();
    opencv = new OpenCV(this, video);
    imageReady = false;
  } else {
    staticImage = loadImage("paper.jpg");
    staticImage.resize(640,360);
    opencv = new OpenCV(this, staticImage);
    imageReady = true;
  }
  
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  //OSC test
  List<PVector> vecs = new ArrayList<PVector>();
  vecs.add(new PVector(100, 100));
  vecs.add(new PVector(150, 100));
  vecs.add(new PVector(150, 150));
  
  
  //vecs.add(DELIM_VEC); 
  vecs.add(new PVector(300, 100)); 
  //vecs.add(DELIM_VEC); 
  vecs.add(new PVector(350, 100)); 
  vecs.add(new PVector(350, 150)); 
  //vecs.add(DELIM_VEC);
  
  
  splitListsAndSendOSC(vecs);
  
  vecs.clear();
  //vecs.add(DELIM_VEC);
}

void draw() {
  if (webcamMode) {
    if (video.available() == true) {
      video.read();
      imageReady = true;
    }
    image(video, 0, 0);
  } else {
    image(staticImage, 0, 0);
  }
  
  fill(0, 255, 0);
  for (int i = 0; i < perspectiveVecs.size(); i++) {
    ellipse(perspectiveVecs.get(i).x, perspectiveVecs.get(i).y, 15, 15);
    text(i, perspectiveVecs.get(i).x + 10, perspectiveVecs.get(i).y);
  }
  
  if (imageReady) performCV();
  setPerspectiveVecs();
}

void keyPressed() {
  //imageReady = true;
  sendToAxidraw = true;
}

/* mouse drag test, works :-D

void mouseDragged() {
  vecs.add(new PVector(mouseX, mouseY));
}


void mouseReleased() {
  println("mouse released");
  vecs.add(DELIM_VEC); 
  splitListsAndSendOSC(vecs);
}
*/

void performCV() {
  if (webcamMode) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(staticImage);
  }
  
  output = createImage(outputWidth, outputHeight, ARGB);
  opencv.toPImage(warpPerspective(perspectiveVecs, outputWidth, outputHeight), output);
  
  //Post effects
  opencv.loadImage(output);
  
  //opencv.blur(5);
  //opencv.threshold(120);
  //output = opencv.getOutput();
  
  faceDetection();
}

void faceDetection() {
  Rectangle[] faces = opencv.detect();
  println(faces.length);
  
  push();
  translate(0, 360);
  if (imageReady) image(output, 0, 0); 
  noFill();
  stroke(0,255,0);
  strokeWeight(2);
  for (int i = 0; i < faces.length; i++) {
    println(faces[i].x + "," + faces[i].y);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  //Perform actions: Be aware that you cannot do multiple actions currently, since sendToAxidraw will become false...
  //crossOutObject(faces);
  //randomLinesOverObject(faces);
  horisontalScribbleOverObject(faces, 25);
  pop();
}

void crossOutObject(Rectangle[] rects) {
  List<PVector> vecs = new ArrayList<PVector>();
  
  stroke(255,0,0);
  for (int i = 0; i < rects.length; i++) {
    
    vecs.add(new PVector(rects[i].x, rects[i].y));
    vecs.add(new PVector(rects[i].x + rects[i].width, rects[i].y+ rects[i].height));
    vecs.add(DELIM_VEC);
    vecs.add(new PVector(rects[i].x, rects[i].y + rects[i].height));
    vecs.add(new PVector(rects[i].x + rects[i].width, rects[i].y));
    
    //draw on this screen
    line(vecs.get(0).x, vecs.get(0).y, vecs.get(1).x, vecs.get(1).y);
    line(vecs.get(3).x, vecs.get(3).y, vecs.get(4).x, vecs.get(4).y);
    
    //send to AxiDraw
    if (sendToAxidraw) {
      splitListsAndSendOSC(vecs);
    }
   
  }
  sendToAxidraw = false;
  vecs.clear(); //is this needed?
} 

void randomLinesOverObject(Rectangle[] rects) {
  List<PVector> vecs = new ArrayList<PVector>();
  
  stroke(0,0,255);
  for (int i = 0; i < rects.length; i++) {    
    for (int n = 0; n<20; n++) {
      vecs.add(new PVector(random(rects[i].x, rects[i].x + rects[i].width), random(rects[i].y, rects[i].y + rects[i].height)));
    }
    
    displayVertex(vecs);
  
    //send to AxiDraw
    if (sendToAxidraw) {
      splitListsAndSendOSC(vecs);
    }
  }
  sendToAxidraw = false;
  vecs.clear(); //is this needed?
} 


void horisontalScribbleOverObject(Rectangle[] rects, int yStep) {
  List<PVector> vecs = new ArrayList<PVector>();
  
  stroke(0);
   for (int i = 0; i < rects.length; i++) {    
    for (int y = 0; y<rects[i].height; y+=yStep) {
      vecs.add(new PVector(rects[i].x, y+rects[i].y));
      vecs.add(new PVector(rects[i].x+rects[i].width, y+rects[i].y + yStep/2));
    }
    displayVertex(vecs);
    
    //send to AxiDraw
    if (sendToAxidraw) {
      splitListsAndSendOSC(vecs);
    }
   }
   sendToAxidraw = false;
  vecs.clear(); //is this needed?
}

//util - does not work for vecs that have a delimiter...
void displayVertex(List<PVector> _vecs) {
    beginShape();
    for (int j = 0; j<_vecs.size(); j++) {
      vertex(_vecs.get(j).x, _vecs.get(j).y);
    }
    endShape(); 
}

//To do
void paintMoustache(Rectangle[] rects) {
  
}

void drawOnEyes(Rectangle[] rects) {
  
}
