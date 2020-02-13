import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;

OpenCV opencv;
PImage src;
PImage card;
int cardWidth = 250;
int cardHeight = 150;

Contour contour;

ArrayList<PVector> myVectors = new ArrayList<PVector>();

void setup() {
  //src = loadImage("cards.png");
  src = loadImage("paper.jpg");
  //size(950, 749);

  size(1200, 600);

  //Order seems to be important...?
  myVectors.add(new PVector(314.0, 344.0)); //Bottom left
  myVectors.add(new PVector(83.0, 370.0)); //Top left
  myVectors.add(new PVector(98.0, 594.0)); //Top right
  myVectors.add(new PVector(353.0, 552.0)); //Bottom right


  opencv = new OpenCV(this, src);

  opencv.blur(1);
  opencv.threshold(120);

  //contour = opencv.findContours(false, true).get(0).getPolygonApproximation();

  card = createImage(cardWidth, cardHeight, ARGB);  
  //opencv.toPImage(warpPerspective(contour.getPoints(), cardWidth, cardHeight), card);
  opencv.toPImage(warpPerspective(myVectors, cardWidth, cardHeight), card);
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


void draw() {
  image(src, 0, 0);
  fill(0, 255, 0);
  for (int i = 0; i < myVectors.size(); i++) {
    ellipse(myVectors.get(i).x, myVectors.get(i).y, 15, 15);
    text(i, myVectors.get(i).x + 10, myVectors.get(i).y);
  }

  pushMatrix();
  translate(src.width, 0);
  image(card, 0, 0);
  popMatrix();
  setLazyPoints();
}

void setLazyPoints() {
  if (mousePressed) {
    for (int i = 0; i < myVectors.size(); i++) {
      if (dist(mouseX, mouseY, myVectors.get(i).x, myVectors.get(i).y)<50) {
        myVectors.get(i).set(mouseX, mouseY);
        opencv.toPImage(warpPerspective(myVectors, cardWidth, cardHeight), card);
      }
    }
  }
}
