//For webcam see https://github.com/bitcraftlab/opencv-webcam-processing/blob/master/examples/LiveCamFindContours/LiveCamFindContours.pde

import gab.opencv.*;
PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

PGraphics pg;

void setup() {
  src = loadImage("line.jpg"); 
  src.resize(540,360);
  size(1080, 360);
  
  pg = createGraphics(540, 360);
  
  //opencv = new OpenCV(this, src);
  opencv = new OpenCV(this, width/2, height);
  opencv.gray();

  pg.beginDraw();
  pg.background(255);
  pg.endDraw();
}

void draw() {
  
  pg.beginDraw();
  pg.stroke(0);
  pg.strokeWeight(5);
  pg.fill(0);
  if (mousePressed) pg.line(mouseX, mouseY, pmouseX, pmouseY);
  pg.endDraw();
  
  image(pg, 0,0);
  PImage screenGrab = get(0,0,width/2, height);
  opencv.loadImage(screenGrab);
  
  opencv.threshold(70);
  dst = opencv.getOutput();

  contours = opencv.findContours();
  
  image(dst, width/2, 0);

  noFill();
  strokeWeight(2);
  
  for (Contour contour : contours) {
    if (contour.area() < width/2*height*0.9) { //Get rid of the big area (the whole thing)
    stroke(0, 255, 0);
    contour.draw();
    
    PVector topPoint = new PVector(0, height);
    PVector bottomPoint = new PVector(0, 0);
    
    stroke(255, 0, 0);
    beginShape();
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      vertex(point.x, point.y);
      ellipse(point.x, point.y, 4, 4);
      
      if (point.y < topPoint.y) topPoint.set(point.x, point.y);
      if (point.y > bottomPoint.y) bottomPoint.set(point.x, point.y);
      
    }
    endShape();
    
    pushStyle();
    fill(0, 0, 255);
    ellipse(topPoint.x, topPoint.y, 10, 10);
    ellipse(bottomPoint.x, bottomPoint.y, 10, 10);
    
    popStyle();
    
    }
  }
}
