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
  
  //OSC test
  List<PVector> vecs = new ArrayList<PVector>();
  vecs.add(new PVector(100, 100));
  vecs.add(new PVector(150, 100));
  vecs.add(new PVector(150, 150));
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(300, 100)); 
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(350, 100)); 
  vecs.add(new PVector(350, 150)); 
  vecs.add(DELIM_VEC);
  
  splitListsAndSendOSC(vecs);
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

  pushMatrix();
  translate(0, 360);
  if (imageReady) image(output, 0, 0);
  popMatrix();
  setPerspectiveVecs();
}

void keyPressed() {
  //imageReady = true;
}

void mousePressed() {
  
}


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
  opencv.blur(5);
  opencv.threshold(120);
  output = opencv.getOutput();
}

void splitListsAndSendOSC(List<PVector> _vectors) {
  final int[] delimIndexes = indicesOf(_vectors, DELIM_VEC);
  List<List<PVector>> vecs2d = splitListAsList2d(_vectors, delimIndexes);

  for (int size = vecs2d.size(), i = 0; i < size; ++i) {
    final List<PVector> vecs1d = vecs2d.get(i);
    println(vecs1d);
    sendOsc(vecs1d);
  }
}

void sendOsc(List<PVector> _vectors) { //send from an flexible ArrayList
  if (_vectors.size()>0) {
    OscMessage msg = new OscMessage("/drawVertex");
    for (int i =0; i<_vectors.size(); i++) { //Remember to cast to ints!
      msg.add((int)_vectors.get(i).x);
      msg.add((int)_vectors.get(i).y);
    }
    oscP5.send(msg, dest);
    println("message sent " + msg);
  } else {
    println("vector not containing anything, message not sent");
  }
}