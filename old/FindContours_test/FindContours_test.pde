import gab.opencv.*;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

void setup() {
  src = loadImage("line.jpg"); 
  src.resize(1080,720);
  size(1080, 360);
  opencv = new OpenCV(this, src);

  opencv.gray();
  opencv.threshold(70);
  dst = opencv.getOutput();

  contours = opencv.findContours();
  println("found " + contours.size() + " contours");
}

void draw() {
  scale(0.5);
  image(src, 0, 0);
  image(dst, src.width, 0);

  noFill();
  strokeWeight(3);
  
  println(contours.size());
  
  for (Contour contour : contours) {
    
    if (contour.area() < width/2*height*0.9) {
    stroke(0, 255, 0);
    //contour.draw();
    
    
    stroke(255, 0, 0);
    beginShape();
    int n = 0;
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      n++;
      println(n);
      vertex(point.x, point.y);
      ellipse(point.x, point.y, 10, 10);
    }
    endShape();
    }
  }
}
