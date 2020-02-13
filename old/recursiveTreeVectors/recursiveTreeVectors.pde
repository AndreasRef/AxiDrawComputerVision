//Attempt to replace all rotate stuff with vector match to avoid issues when drawing with axidraw....

void setup() {
  size(640, 360);
}

void draw() {
  background(255);
  stroke(0);
 
  PVector bottomVec = new PVector(width/2, height-20);
  PVector topVec = new PVector(width/2, height-120);
  PVector diffVector = PVector.sub(bottomVec, topVec);
    
  float a = -(atan2(diffVector.x,diffVector.y)); //Somehow angles are inverted, fix this
  
  pushMatrix();
  translate(topVec. x, topVec.y);
  line(0, 0, diffVector.x, diffVector.y);
  //rotate((a)); 
  
  //branch(diffVector.mag()); 
  vectorBranch(diffVector);
  popMatrix();
}

void vectorBranch(PVector myVec) {
  
  PVector lVec = myVec;
  PVector rVec = myVec;
  
  println(myVec);
  
  float theta = radians(30); 
  // Each branch will be 2/3rds the size of the previous one
  //h *= 0.66;
  
  myVec.mult(0.66);
  
  //The issue might be, that the vector is not reset in its size and/or rotation?
  
  
  
  //PVector bV = new PVector(0,h);
  
  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (myVec.mag() > 2) {
    //println(myVec.mag());
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    //rotate(theta);   // Rotate by theta
    //myVec.rotate(theta);
    //line(0, 0, myVec.x, -myVec.y);  // Draw the branch
    //translate(0, -myVec.y); // Move to the end of the branch
    
    //vectorBranch(myVec);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    
    //myVec.set(0,myVec.mag());
    
    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-theta);
    //myVec.rotate(-theta);
    line(0, 0, myVec.x, -myVec.y);
    ellipse(myVec.x, -myVec.y, 5, 5);
    translate(0, -myVec.y);
    vectorBranch(myVec);
    popMatrix();
    
  } 
}

void branch(float h) {
  
  float theta = radians(30);
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.66;
  
  PVector bV = new PVector(0,h);
  
  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (h > 2) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(theta);   // Rotate by theta
    line(0, 0, bV.x, -bV.y);  // Draw the branch
    translate(0, -h); // Move to the end of the branch
    branch(h);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    
    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-theta);
    line(0, 0, bV.x, -bV.y);
    translate(0, -h);
    branch(h);
    popMatrix();
    
  } 
}
