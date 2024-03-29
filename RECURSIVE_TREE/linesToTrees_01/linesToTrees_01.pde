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

      pushStyle();
      fill(0, 0, 255);
      ellipse(topPoint.x, topPoint.y, 10, 10);
      ellipse(bottomPoint.x, bottomPoint.y, 10, 10);

      popStyle();

      //Draw recursive trees
      PVector diffVector = PVector.sub(bottomPoint, topPoint);    
      float a = -(atan2(diffVector.x, diffVector.y));
      println("a: " + a);  


      pushMatrix();
      pushStyle();
      translate(topPoint.x, topPoint.y);
      stroke(125, 0, 125);
      line(0, 0, diffVector.x, diffVector.y);
      rotate((a)); 
      stroke(255, 0, 255);
      if (mousePressed == false) branch(diffVector.mag(), 0); 
      popStyle();
      popMatrix();
    }
  }
}

void branch(float h, float lineAngle) {
  float theta = radians(30);
  // Each branch will be x the size of the previous one
  h *= 0.6;

  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is x pixels or less
  if (h > 2) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(theta + radians(lineAngle));   // Rotate by theta
    //line(0, 0, 0, -h);  // Draw the branch as straight line
    //draw the branch more curved/random
    drawNoisyBranches(h, 10);
    translate(0, -h); // Move to the end of the branch
    branch(h, lineAngle);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state

    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-theta+radians(lineAngle));
    //line(0, 0, 0, -h);  // Draw the branch as straight line
    //draw the branch more curved/random
    drawNoisyBranches(h, 10);
    translate(0, -h);
    branch(h, lineAngle);
    popMatrix();
  }
}


void drawNoisyBranches(float h, float noiseFactor) { //Needs more work!
  beginShape();
    for (int i =0; i<h; i+=5) {
      vertex(noise(i*0.001)*noiseFactor-noiseFactor/2,-i);
    }
  endShape();
}

void keyPressed() {
   if (key == ' ' ) {
     pg.clear(); 
   }
}
