float theta;   

void setup() {
  size(640, 360);
  noLoop();
}

void draw() {
  background(0);
  frameRate(30);
  stroke(255);
  // Let's pick an angle 0 to 95 degrees based on the mouse position
  //float a = (mouseX / (float) width) * 95f;
  float a = 30;
  // then cap it at 90 degrees
  a = min(a, 90); 
  // Convert it to radians
  theta = radians(a);
  // Start the recursive branching!
  branch(new PVector(width/2, height-120), -PI/2, theta, 120);
}

//Recursion without translate + rotate: https://discourse.processing.org/t/recursive-tree-without-using-rotate/17080/5
void branch(PVector parent, float branch_angle, float delta_angle, float h) {  
  // Each branch will be 2/3rds the size of the previous one
  h *= random(0.5,0.75);
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
    noisyLine(parent, new PVector(lineEnd_x, lineEnd_y), 0.15, 5.0, 0.1, random(100), random(100)); 
    branch(new PVector(lineEnd_x, lineEnd_y), ccw_angle, delta_angle, h);
    // Right branch
    //Anticlockwise branch
    cw_angle = branch_angle + delta_angle;
    delta_x = h * cos(cw_angle);
    delta_y = h * sin(cw_angle);
    lineEnd_x = parent.x + delta_x;
    lineEnd_y = parent.y + delta_y;
    //line(parent.x, parent.y, lineEnd_x, lineEnd_y);
    noisyLine(parent, new PVector(lineEnd_x, lineEnd_y), 0.15, 5.0, 0.1, random(100), random(100)); 
    branch(new PVector(lineEnd_x, lineEnd_y), cw_angle, delta_angle, h);
  }
}

void mousePressed() {
 redraw(); 
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
