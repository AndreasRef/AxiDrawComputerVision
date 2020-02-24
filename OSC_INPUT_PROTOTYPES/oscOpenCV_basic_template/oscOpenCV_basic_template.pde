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

final PVector DELIM_VEC = new PVector(0, 0);

Capture video;
OpenCV opencv;
PImage staticImage;
PImage output;
int outputWidth = 640;
int outputHeight = 360;

Contour contour;
ArrayList<PVector> perspectiveVecs = new ArrayList<PVector>();
boolean imageReady;
;
Boolean webcamMode = true;

Table table; //Table for storing perspectivePoints

boolean sendToAxidraw = false;

float xScaleFactor = 740.0/640.0;
float yScaleFactor = 523.0/360.0;

void setup() {
  size(640, 720);
  surface.setLocation(0, 100);
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 12000);

  loadPerspectiveVecs();

  if (webcamMode) {
    String[] cameras = Capture.list();
    println(cameras);
    video = new Capture(this, 640, 360, cameras[0]);
    video.start();
    opencv = new OpenCV(this, video);
    imageReady = false;
  } else {
    staticImage = loadImage("paper.jpg");
    staticImage.resize(640, 360);
    opencv = new OpenCV(this, staticImage);
    imageReady = true;
  }
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
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

void performCV() {
  if (webcamMode) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(staticImage);
  }

  output = createImage(outputWidth, outputHeight, ARGB);
  opencv.toPImage(warpPerspective(perspectiveVecs, outputWidth, outputHeight), output);

  //Get the warped image
  opencv.loadImage(output);
  
  //Perform post effects
  opencv.blur(5);
  opencv.threshold(120);
  output = opencv.getOutput();
  
  //Draw the image to screen
  push();
  translate(0, 360);
  if (imageReady) image(output, 0, 0); 
  pop();  
  
  //Do specific action
  faceDetection();
}


void faceDetection() {
  Rectangle[] faces = opencv.detect();

  push();
  translate(0, 360);
  if (imageReady) image(output, 0, 0); 
  noFill();
  stroke(0, 255, 0);
  strokeWeight(2);
  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  //Perform actions: Be aware that you cannot do multiple simultanious actions currently
  //since sendToAxidraw will become false...
  randomLinesOverObject(faces);

  pop();
}

void randomLinesOverObject(Rectangle[] rects) {
  List<PVector> vecs = new ArrayList<PVector>();
  vecs.add(DELIM_VEC);

  stroke(0, 0, 255);
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

void displayVertex(List<PVector> _vecs) {
  beginShape();
  for (int i = 0; i<_vecs.size(); i++) {
    if (!_vecs.get(i).equals(DELIM_VEC)) { //quick fix for delimiter
      vertex(_vecs.get(i).x, _vecs.get(i).y);
    }
  }
  endShape();
}
