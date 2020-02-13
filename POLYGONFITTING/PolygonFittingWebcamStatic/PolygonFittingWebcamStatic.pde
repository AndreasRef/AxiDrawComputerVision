import boofcv.processing.*;
import boofcv.struct.image.*;
import georegression.struct.point.*;
import georegression.struct.curve.*;
import java.util.*;
import processing.video.*;

Capture cam;

PImage staticImage;
List<List<Point2D_I32>> polygons;
List<EllipseRotated_F64> external;

Boolean webcamMode = false;

void setup() {
  size(640, 480);

  if (webcamMode) {
    String[] cameras = Capture.list();
    println("Available cameras:");
    printArray(cameras);
    cam = new Capture(this, width, height, cameras[0]);
    cam.start();
  } else {
    staticImage = loadImage("photo.jpg");
    staticImage.resize(width, height);
    performCV(staticImage);
  }
}

void performCV(PImage input) {
  // Convert the image into a simplified BoofCV data type
  SimpleGray gray = Boof.gray(input, ImageDataType.F32);

  // Find the initial set of contours automatically select a threshold// using the Otsu method
  SimpleContourList contours = gray.thresholdOtsu(false).erode8(1).contour().getContours();

  //For black/white images
  //double threshold = 50;
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
}

void draw() {

  if (webcamMode) {

    if (cam.available() == true) {
      cam.read();
    }

    image(cam, 0, 0, width, height);

    performCV(cam);
  } else {
    image(staticImage, 0, 0, width, height);
  }

  if (external != null) {
    noFill();
    strokeWeight(1);
    drawPolygonsUsingLines(external);
    drawOuterPolygons();
  }
}

void drawOuterPolygons() {
  stroke(0, 255, 0);

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
  stroke(255);

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
        vertex(p.x*scaleFactor + translateVector.x, p.y*scaleFactor + translateVector.y);
      }
      // close the loop
      Point2D_I32 p = poly.get(0);
      vertex( p.x*scaleFactor + translateVector.x, p.y*scaleFactor + translateVector.y);
      endShape();
    }
  }
}


void keyPressed() {
}
