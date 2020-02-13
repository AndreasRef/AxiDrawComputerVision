void setup() {
  size(640, 360);
}

void draw() {
  background(255);
  stroke(0);
 
  PVector bottomVec = new PVector(mouseX, mouseY);
  PVector topVec = new PVector(width/2, height-120);
  PVector diffVector = PVector.sub(bottomVec, topVec);
    
  float a = -(atan2(diffVector.x,diffVector.y)); //Somehow angles are inverted, fix this
  
  pushMatrix();
  translate(topVec. x, topVec.y);
  line(0, 0, diffVector.x, diffVector.y);
  rotate((a)); 
  
  branch(diffVector.mag(), 0); 
  popMatrix();
}

void branch(float h, float lineAngle) {
  
  float theta = radians(30);
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.66;
  
  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (h > 2) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(theta + radians(lineAngle));   // Rotate by theta
    line(0, 0, 0, -h);  // Draw the branch
    translate(0, -h); // Move to the end of the branch
    branch(h, lineAngle);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    
    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-theta+radians(lineAngle));
    line(0, 0, 0, -h);
    translate(0, -h);
    branch(h, lineAngle);
    popMatrix();
    
  } 
}
