import gab.opencv.*;

OpenCV opencv;
ArrayList<Line> lines;

PGraphics pg; 

void setup() {
  PImage src = loadImage("film_scan.jpg");
  
  
  
  src.resize(0, 800);
  size(796, 800);
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.background(255);
  pg.endDraw();

}
 
void draw() { 
  
  pg.beginDraw();
  pg.fill(0);
  if (mousePressed) pg.line(mouseX, mouseY, pmouseX, pmouseY);
  pg.endDraw();
  image(pg, 0, 0);
  
  if (keyPressed) {
  
  PImage myImg = get();
  
  opencv = new OpenCV(this, myImg);
  opencv.findCannyEdges(20, 75);
  image(opencv.getOutput(), 0, 0);
  strokeWeight(3);
  
  // Find lines with Hough line detection
  // Arguments are: threshold, minLengthLength, maxLineGap
  lines = opencv.findLines(100, 100, 50);
  
  println(lines.size());
  
  for (Line line : lines) {
    // lines include angle in radians, measured in double precision
    // so we can select out vertical and horizontal lines
    // They also include "start" and "end" PVectors with the position
    if (line.angle >= radians(0) && line.angle < radians(1)) {
      stroke(0, 255, 0);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }

    if (line.angle > radians(89) && line.angle < radians(91)) {
      stroke(255, 0, 0);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }
    
    else {
      stroke(0, 0, 255);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }
  }
}
}
