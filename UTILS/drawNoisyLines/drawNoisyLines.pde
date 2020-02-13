void setup() {
 size(640, 360); 
 noLoop();
}

void draw() {
 background(255);
 randomLine(new PVector(200, 100), new PVector(250, 300), 0.05, 2.0);
 noisyLine(new PVector(100, 100), new PVector(150, 300), 0.05, 125.0, 0.1, random(100), random(100));
}

void mousePressed() {
 redraw(); 
}

void randomLine(PVector start, PVector stop, float incStep, float randomFactor) {
  beginShape();
  vertex(start.x, start.y);
  //ellipse(start.x, start.y, 5, 5);
  for (float i = incStep; i<1; i+=incStep) {
    PVector lerpVector = PVector.lerp(start,stop,i);
    lerpVector.add(random(-randomFactor,randomFactor),random(-randomFactor,randomFactor),0);
    vertex(lerpVector.x, lerpVector.y);
    //ellipse(lerpVector.x, lerpVector.y, 5, 5);
  }
  //ellipse(stop.x, stop.y, 5, 5);
  vertex(stop.x, stop.y);
  endShape();
}

void noisyLine(PVector start, PVector stop, float incStep, float noiseFactor, float noiseInc, float xOff, float yOff) {
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
