//To do

//Better CV interface, so you can actually sense what the computer sees
//Long term: Place white stuff where you just drew, to avoid drawing on top of the same figure again
//For this see UTILS/PImageSetPixels

//PolygonFitting
import boofcv.processing.*;
import boofcv.struct.image.*;
import georegression.struct.point.*;
import georegression.struct.curve.*;


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

Boolean webcamMode = false;

Table table; //Table for storing perspectivePoints

boolean sendToAxidraw = false;

float xScaleFactor = 740.0/640.0;
float yScaleFactor = 523.0/360.0;

//Polygon fitting
List<List<Point2D_I32>> polygons;
List<EllipseRotated_F64> external;


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
    staticImage = loadImage("photo.jpg");
    staticImage.resize(640, 360);
    opencv = new OpenCV(this, staticImage);
    imageReady = true;
  }
  //opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
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
  //faceDetection();
  performCV(output);
}

void performCV(PImage input) {
  // Convert the image into a simplified BoofCV data type
  SimpleGray gray = Boof.gray(input, ImageDataType.F32); //is this needed?

  // Find the initial set of contours automatically select a threshold// using the Otsu method
  SimpleContourList contours = gray.thresholdOtsu(false).erode8(1).contour().getContours();
  

  //For black/white images
  //double threshold = 150;
  //SimpleContourList contours = gray.threshold(threshold, true).erode8(1).contour().getContours();

  // Filter contours which are too small
  List<SimpleContour> list = contours.getList();
  List<SimpleContour> prunedList = new ArrayList<SimpleContour>();

  for ( SimpleContour c : list ) {
    if ( c.getContour().external.size() >= 200  && c.getContour().external.size() <1000) {
      prunedList.add( c );
    }
  }

  // Create a new contour list
  contours = new SimpleContourList(prunedList, input.width, input.height);

  // Fit polygons to external contours
  polygons = contours.fitPolygons(true, 20, 0.25);
  external = contours.fitEllipses(true);

  println("polygons found: " + polygons.size());
  println("ellipses found: " + external.size());

  //Draw stuff on screen for Polygon fitting
  if (external != null) {
    push();
    translate(0, 360);
    noFill();
    strokeWeight(1);
    drawPolygonsUsingLines(external);
    drawOuterPolygons();
    pop();
  }
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


void drawOuterPolygons() {
  stroke(0, 255, 0); //green lines

  // Draw each polygon
  for ( List<Point2D_I32> poly : polygons ) {
    if ( poly.size() == 0 )
      continue;
    beginShape();
    for ( Point2D_I32 p : poly) {
      vertex( p.x, p.y );
    }
    // close the loop
    Point2D_I32 p = poly.get(0);
    vertex( p.x, p.y );
    endShape();
  }
}

void drawPolygonsUsingLines(List<EllipseRotated_F64> ellipses) {

  //Perhaps split the drawing and the sending?
  List<PVector> vecs = new ArrayList<PVector>();

  stroke(255, 0, 0); // red
  //vectors.clear();

  for (int i=0; i<ellipses.size(); i++) {
    EllipseRotated_F64 e = ellipses.get(i);
    List<Point2D_I32> poly = polygons.get(i);

    float iterations = 5.0;     
    for (int k = 0; k<iterations; k++) { 

      PVector translateVector = new PVector((float)e.center.x*k*(1/iterations), (float)e.center.y*k*(1/iterations));
      float scaleFactor = 1.0-k*(1/iterations);

      //Draw polygons
      if ( poly.size() == 0 )
        continue;
      beginShape();
      for ( Point2D_I32 p : poly) {
        PVector pointVec = new PVector(p.x*scaleFactor + translateVector.x, p.y*scaleFactor + translateVector.y);
        vertex(pointVec.x, pointVec.y);
        vecs.add(pointVec);
      }

      // close the loop
      Point2D_I32 p = poly.get(0);
      PVector pointVec = new PVector(p.x*scaleFactor + translateVector.x, p.y*scaleFactor + translateVector.y);
      vertex(pointVec.x, pointVec.y);
      vecs.add(pointVec);
      endShape();
      vecs.add(new PVector(0, 0)); //Add the break vector to ensure that lines are not all connected
    }
  }
  
  //send to AxiDraw
  if (sendToAxidraw) {
    splitListsAndSendOSC(vecs);
  }
  sendToAxidraw = false;
}
