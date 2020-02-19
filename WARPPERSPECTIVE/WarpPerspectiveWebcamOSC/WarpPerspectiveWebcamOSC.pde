//To do
//Function to calculate outPut coordinates to paper coordinates
//Basic proof of concept example (but with which example)
//Clean up: move util functions to other tabs

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

final List<PVector> vecs = new ArrayList<PVector>();
final PVector DELIM_VEC = new PVector(0,0);
List<List<PVector>> vecs2d;

Capture video;
OpenCV opencv;
PImage staticImage;
PImage output;
int outputWidth = 640;
int outputHeight = 360;

Contour contour;
ArrayList<PVector> perspectiveVecs = new ArrayList<PVector>();
boolean cvCalculated = false;
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
  } else {
    staticImage = loadImage("paper.jpg");
    staticImage.resize(640,360);
    opencv = new OpenCV(this, staticImage);
    cvCalculated = true;
  }
  
  //OSC test
  vecs.add(new PVector(100, 100));
  vecs.add(new PVector(150, 100));
  vecs.add(new PVector(150, 150));
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(300, 100)); 
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(350, 100)); 
  vecs.add(new PVector(350, 150)); 
  vecs.add(DELIM_VEC);
  
  final int[] delimIndexes = indicesOf(vecs, DELIM_VEC);

  vecs2d = splitListAsList2d(vecs, delimIndexes);

  for (final List<PVector> vecs1d : vecs2d) {
    println(vecs1d); //This is where we get the correct lists..
    sendOsc(vecs1d);
  }
  
}

void draw() {
  if (webcamMode) {
    if (video.available() == true) {
      video.read();
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

  if (cvCalculated) performCV();

  pushMatrix();
  translate(0, 360);
  if (cvCalculated) image(output, 0, 0);
  popMatrix();
  setLazyPoints();
}

void keyPressed() {
  cvCalculated = true;
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

void setLazyPoints() {
  if (mousePressed && cvCalculated) {
    for (int i = 0; i < perspectiveVecs.size(); i++) {
      if (dist(mouseX, mouseY, perspectiveVecs.get(i).x, perspectiveVecs.get(i).y)<50) {
        perspectiveVecs.get(i).set(mouseX, mouseY);
        opencv.toPImage(warpPerspective(perspectiveVecs, outputWidth, outputHeight), output);
      }
    }
    savePerspectiveVecs();
  }
}

void loadPerspectiveVecs() {
  
  table = loadTable("data.csv", "header");  
  //println(table.getRowCount());
  for (TableRow row : table.rows()) {
    float x = row.getInt(0);
    float y = row.getInt(1);
    perspectiveVecs.add(new PVector(x, y)); 
  }
  
  /*Order of the Vectors seems to be important...?
   1------0          
   |      |
   2------3
   
  perspectiveVecs.add(new PVector(500.0, 10.0));   //0: Top right
  perspectiveVecs.add(new PVector(10.0, 10.0));    //1: Top left
  perspectiveVecs.add(new PVector(10.0, 350.0));   //2: Bottom right
  perspectiveVecs.add(new PVector(500.0, 350.0));  //3: Bottom left
  */
  
}

void savePerspectiveVecs() {
  table = new Table();
  table.addColumn("x", Table.INT);
  table.addColumn("y", Table.INT);

  for (int i = 0; i<4; i++) {
    TableRow row = table.addRow();
    row.setInt("x", (int) perspectiveVecs.get(i).x);
    row.setInt("y", (int) perspectiveVecs.get(i).y);
  }
  saveTable(table, "data/data.csv");  
}

Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
  Point[] canonicalPoints = new Point[4];
  canonicalPoints[0] = new Point(w, 0);
  canonicalPoints[1] = new Point(0, 0);
  canonicalPoints[2] = new Point(0, h);
  canonicalPoints[3] = new Point(w, h);

  MatOfPoint2f canonicalMarker = new MatOfPoint2f();
  canonicalMarker.fromArray(canonicalPoints);

  Point[] points = new Point[4];
  for (int i = 0; i < 4; i++) {
    points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
  }
  MatOfPoint2f marker = new MatOfPoint2f(points);
  return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
}

Mat warpPerspective(ArrayList<PVector> inputPoints, int w, int h) {
  Mat transform = getPerspectiveTransformation(inputPoints, w, h);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
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
