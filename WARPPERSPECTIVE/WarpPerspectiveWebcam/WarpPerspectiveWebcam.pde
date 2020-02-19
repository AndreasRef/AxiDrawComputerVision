//To do
//Switch between static mode and webcam mode
//Save positions after closing program
//p5gui?
//perform openCV stuff on outputImage

import processing.video.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

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
  loadData();
  surface.setLocation(0, 100);
  if (webcamMode) {
    String[] cameras = Capture.list();
    video = new Capture(this, 640, 360, cameras[0]);
    video.start();
  } else {
    staticImage = loadImage("paper.jpg");
    staticImage.resize(640,360);
    cvCalculated = true;
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
    opencv = new OpenCV(this, video);
  } else {
    opencv = new OpenCV(this, staticImage);
  }
  
  output = createImage(outputWidth, outputHeight, ARGB);
  //opencv.loadImage(video);
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
    saveData();
  }
}

void loadData() {
  
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

void saveData() {
  table = new Table();
  table.addColumn("x", Table.INT);
  table.addColumn("y", Table.INT);

  for (int i = 0; i<4; i++) {
    TableRow row = table.addRow();
    row.setInt("x", (int) perspectiveVecs.get(i).x);
    row.setInt("y", (int) perspectiveVecs.get(i).y);
  }
  
  saveTable(table, "data/data.csv");
  
  /*
  table = loadTable("data.csv"); //not elegant
  table.clearRows();
  
  for (int i = 0; i < perspectiveVecs.size(); i++) {
    TableRow row = table.addRow();
    row.setInt((int) perspectiveVecs.get(i).x, (int) perspectiveVecs.get(i).y);
    //row.setInt();
  }
  
  saveTable(table, "data/data.csv");
  
  */
  
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
