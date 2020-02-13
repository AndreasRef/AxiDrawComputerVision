float theta;   

void setup() {
  size(640, 360);
}

void draw() {
  background(0);
  frameRate(30);
  stroke(255);
  // Let's pick an angle 0 to 95 degrees based on the mouse position
  float a = (mouseX / (float) width) * 95f;
  // then cap it at 90 degrees
  a = min(a, 90); 
  // Convert it to radians
  theta = radians(a);
  // Start the tree from the bottom of the screen
  translate(width/2, height);
  // Draw a line 120 pixels
  line(0, 0, 0, -120);
  // Move to the end of that line
  translate(0, -120);
  // Start the recursive branching!
  branch(new PVector(0, 0), -PI/2, theta, 120);
}

//Recursion without translate + rotate: https://discourse.processing.org/t/recursive-tree-without-using-rotate/17080/5
void branch(PVector parent, float branch_angle, float delta_angle, float h) {  
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.66;
  if (h > 2) {
    float ccw_angle, cw_angle, delta_x, delta_y;
    // Left branch
    //Anticlockwise branch
    ccw_angle = branch_angle - delta_angle;
    delta_x = h * cos(ccw_angle);
    delta_y = h * sin(ccw_angle);
    line(parent.x, parent.y, parent.x + delta_x, parent.y + delta_y);
    branch(new PVector(parent.x + delta_x, parent.y + delta_y), ccw_angle, delta_angle, h);
    // Right branch
    //Anticlockwise branch
    cw_angle = branch_angle + delta_angle;
    delta_x = h * cos(cw_angle);
    delta_y = h * sin(cw_angle);
    line(parent.x, parent.y, parent.x + delta_x, parent.y + delta_y);
    branch(new PVector(parent.x + delta_x, parent.y + delta_y), cw_angle, delta_angle, h);
  }
}
