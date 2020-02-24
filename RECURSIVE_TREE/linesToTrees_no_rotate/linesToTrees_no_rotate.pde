//For webcam see https://github.com/bitcraftlab/opencv-webcam-processing/blob/master/examples/LiveCamFindContours/LiveCamFindContours.pde

/*To do: Get some measurement for how curvy the lines are...
 Clean up UI
 Improve noise thing
 Nice to have: Timing thing for the drawing of lines
 Could we get rid of the translate? Will sync with the AxiDraw? I Guess it should work, since there is a "move relative" function...
 https://github.com/evil-mad/AxiDraw-Processing/blob/master/AxiGen1/AxiControl.pde
 Could we get rid of rotate? I am not sure how that would work with Axidraw...
 Could I re-write the entire branch function with vectors only...?
 */

import gab.opencv.*;
PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

PGraphics pg;

float theta;

float xOffLeft, yOffLeft, xOffRight, yOffRight;

void setup() {
  src = loadImage("line.jpg"); 
  src.resize(540, 360);
  size(1080, 360);
  pg = createGraphics(width/2, height);

  opencv = new OpenCV(this, width/2, height);
  opencv.gray();

  pg.beginDraw();
  pg.background(255);
  pg.endDraw();
  
  xOffLeft = random(100);
  yOffLeft = random(100);
  xOffRight = random(100);
  yOffRight = random(100); 
}

void draw() {
  background(255);
  pg.beginDraw();
  pg.stroke(0);
  pg.strokeWeight(5);
  pg.fill(0);
  if (mousePressed) pg.line(mouseX, mouseY, pmouseX, pmouseY);
  pg.endDraw();

  image(pg, 0, 0);
  PImage screenGrab = get(0, 0, width/2, height);
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

      push();
      fill(0, 0, 255); //Blue topPoint
      ellipse(topPoint.x, topPoint.y, 10, 10);
      fill(255, 0, 255); //Magenta bottomPoint
      ellipse(bottomPoint.x, bottomPoint.y, 10, 10);
      pop();

      PVector diffVector = PVector.sub(bottomPoint, topPoint);    
      float branchA = -atan2(diffVector.x, diffVector.y)-PI/2;
            
      float a = 30; //Angle for branch spread
      a = min(a, 90); // then cap it at 90 degrees
      theta = radians(a); // Convert it to radians
      
      println(branchA);
      branch(topPoint, branchA, theta, diffVector.mag());
    }
  }
}
//Recursion without translate + rotate: https://discourse.processing.org/t/recursive-tree-without-using-rotate/17080/5
void branch(PVector parent, float branch_angle, float delta_angle, float h) {  
  // Each branch will be 2/3rds the size of the previous one
  //h *= random(0.5,0.75);
  h *= 0.66;
  if (h > 2) {
    float ccw_angle, cw_angle, delta_x, delta_y, lineEnd_x, lineEnd_y;
    // Left branch
    //Anticlockwise branch
    ccw_angle = branch_angle - delta_angle;
    delta_x = h * cos(ccw_angle);
    delta_y = h * sin(ccw_angle);
    lineEnd_x = parent.x + delta_x;
    lineEnd_y = parent.y + delta_y;
    //line(parent.x, parent.y, lineEnd_x, lineEnd_y);
    //noisyLine(parent, new PVector(lineEnd_x, lineEnd_y), 0.15, 5.0, 0.1, random(100), random(100)); 
    noisyLine(parent, new PVector(lineEnd_x, lineEnd_y), 0.15, 5.0, 0.1, xOffLeft, yOffLeft);
    branch(new PVector(lineEnd_x, lineEnd_y), ccw_angle, delta_angle, h);
    // Right branch
    //Anticlockwise branch
    cw_angle = branch_angle + delta_angle;
    delta_x = h * cos(cw_angle);
    delta_y = h * sin(cw_angle);
    lineEnd_x = parent.x + delta_x;
    lineEnd_y = parent.y + delta_y;
    //line(parent.x, parent.y, lineEnd_x, lineEnd_y);
    //noisyLine(parent, new PVector(lineEnd_x, lineEnd_y), 0.15, 5.0, 0.1, random(100), random(100));
    noisyLine(parent, new PVector(lineEnd_x, lineEnd_y), 0.15, 5.0, 0.1, xOffRight, yOffRight);
    branch(new PVector(lineEnd_x, lineEnd_y), cw_angle, delta_angle, h);
  }
}




void noisyLine(PVector start, PVector stop, float incStep, float noiseFactor, float noiseInc, float xOff, float yOff) {
  noFill();
  beginShape();
  vertex(start.x, start.y);
  for (float i = incStep; i<1; i+=incStep) {
    PVector lerpVector = PVector.lerp(start,stop,i);
    float softener = min(abs(1.0-abs(0.5-i)*2),0.8); //make noiseFactor less in the ends to avoid ugly cuts...
    lerpVector.add((noise(xOff)-0.5)*noiseFactor*softener,(noise(yOff)-0.5)*noiseFactor*softener,0);
    vertex(lerpVector.x, lerpVector.y);
    xOff+=noiseInc;
    yOff+=noiseInc;
  }
  vertex(stop.x, stop.y);
  endShape();
}



void keyPressed() {
  if (key == ' ' ) {
    pg.clear();
  }
}
