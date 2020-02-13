// Converts the image into a binary image, finds the contours of each blob, and then fits
// a polygon to each external contour.

import boofcv.processing.*;
import boofcv.struct.image.*;
import georegression.struct.point.*;
import georegression.struct.curve.*;
import java.util.*;

PImage staticImage;
List<List<Point2D_I32>> polygons;
List<EllipseRotated_F64> external;

void setup() {
  size(640, 480);
  staticImage = loadImage("photo.jpg");
  staticImage.resize(width, height);
  
  performCV(staticImage);
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
  
  println(external.size());
  
}

void draw() {
  // Toggle between the background image and a solid color for clarity
  if ( mousePressed ) {
    background(0);
  } else {
    image(staticImage, 0, 0);
  }
  noFill();
  strokeWeight(3);
  drawPolygonsWithinThemselves(external);
  drawOuterPolygons();
}

void drawOuterPolygons() {
  stroke(0, 255, 0);

  // Draw each polygon
  for ( List<Point2D_I32> poly : polygons ) {
    if( poly.size() == 0 )
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

void drawPolygonsWithinThemselves( List<EllipseRotated_F64> ellipses) {
  stroke(255);

  for (int i=0; i<ellipses.size(); i++) {
    EllipseRotated_F64 e = ellipses.get(i);
    List<Point2D_I32> poly = polygons.get(i);

   float iterations = 10.0;     
   for (int k = 0; k<iterations; k++) { 
     pushMatrix();
     translate((float)e.center.x*k*(1/iterations), (float)e.center.y*k*(1/iterations));
     //scale(1.0-k*(1/iterations));
     float scaleFactor = 1.0-k*(1/iterations);
    //Draw polygons
    if ( poly.size() == 0 )
      continue;
    beginShape();
    for ( Point2D_I32 p : poly) {
      vertex( p.x*scaleFactor, p.y*scaleFactor);
    }
    // close the loop
    Point2D_I32 p = poly.get(0);
    vertex( p.x*scaleFactor, p.y*scaleFactor);
    endShape();
    popMatrix();
   }
  }
}
