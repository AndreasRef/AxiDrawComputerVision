import java.awt.*;
import java.util.List;
Rectangle[] rects = new Rectangle[1];

final PVector DELIM_VEC = new PVector(0, 0);

void setup() {
  size(600, 400);
  background(255);
  rects[0] = new Rectangle(100, 100, 400, 200); 
  
  //rects[1] = new Rectangle(200, 200, 200, 200); 
  fill(255);
  rect(rects[0].x, rects[0].y, rects[0].width, rects[0].height);
  humanLikeHatching(rects, 5, 5);
  sloppyCircleHatching(rects);
}

void sloppyCircleHatching(Rectangle[] rects) {
  List<PVector> vecs = new ArrayList<PVector>();  
  stroke(255,0,0);
  
    for (int i = 0; i < rects.length; i++) {
    
    for (int repetitions = 0; repetitions<500; repetitions++) {
      float x = random(rects[i].x, rects[i].x + rects[i].width);
      float y = random(rects[i].y, rects[i].y + rects[i].height);
      
      if (dist(x,y, (float) rects[i].getCenterX(), (float) rects[i].getCenterY()) <min(rects[i].width, rects[i].height)/2) {
        vecs.add(new PVector(x, y));
      }
    }
      
  
    beginShape();
    for (int n = 0; n < vecs.size(); n++) {
      vertex(vecs.get(n).x, vecs.get(n).y);
    }
    endShape();
  }
  
}

void humanLikeHatching(Rectangle[] rects, int randomFactor, int incStep) {
  List<PVector> vecs = new ArrayList<PVector>();  
  stroke(0);
  noFill();
  strokeWeight(1);
  for (int i = 0; i < rects.length; i++) {
    for (int y = rects[i].y; y< rects[i].y+ rects[i].height; y+=incStep) {
      for (int x = rects[i].x; x<rects[i].x+rects[i].width; x+=incStep) {
        //vertex(x + random(-randomFactor, randomFactor), y+random(-randomFactor, randomFactor));
        vecs.add(new PVector(x + random(-randomFactor, randomFactor), y+random(-randomFactor, randomFactor)));
        //ellipse(x + random(-randomFactor,randomFactor), y+random(-randomFactor, randomFactor), 2, 2);
      }
    }
    beginShape();
    for (int n = 0; n < vecs.size(); n++) {
      vertex(vecs.get(n).x, vecs.get(n).y);
    }
    endShape();
  }
}



void crossOutObject(Rectangle[] rects) {
  List<PVector> vecs = new ArrayList<PVector>();  
  stroke(0);
  for (int i = 0; i < rects.length; i++) {

    vecs.add(new PVector(rects[i].x, rects[i].y));
    vecs.add(new PVector(rects[i].x + rects[i].width, rects[i].y+ rects[i].height));
    vecs.add(DELIM_VEC);
    vecs.add(new PVector(rects[i].x, rects[i].y + rects[i].height));
    vecs.add(new PVector(rects[i].x + rects[i].width, rects[i].y));

    //draw on this screen
    line(vecs.get(0).x, vecs.get(0).y, vecs.get(1).x, vecs.get(1).y);
    line(vecs.get(3).x, vecs.get(3).y, vecs.get(4).x, vecs.get(4).y);
  }
}
