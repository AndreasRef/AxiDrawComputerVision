/*
To do
- Draw on the canvas instead of loading the image
- Detect the average x of the y points

*/

import blobscanner.*;
PImage blobs;
Detector bs;
int bn = 0;

PGraphics pg;

void setup() {
  size(400, 300);
  pg = createGraphics(width, height);
  bs = new Detector(this, 255);  
}

void draw() {
  
  background(0);
  fill(255);
  line(10,10, 100, 100);
  line(200,10, 150, 100);
  
  line(width/2,height/2, mouseX, mouseY);
  
  pg.beginDraw();
  pg.stroke(255);
  pg.strokeWeight(10);
  pg.background(0);
  pg.line(200,10, 150, 100);
  pg.endDraw();
  
  image(pg, 200, 200, 200, 200);
  
  PImage canvasImg = get();

  bs.imageFindBlobs(canvasImg);
  bs.loadBlobsFeatures();
  

  stroke(255, 0, 0);
  strokeWeight(5);

  for (int n = 0; n<bs.getBlobsNumber(); n++) {
    
    PVector topY = new PVector(0,height);
    PVector bottomY = new PVector(0,0);
    PVector[] edge = bs.getEdgePoints(n);
    for (int i = 0; i<edge.length; i++) {
      point(edge[i].x, edge[i].y );
      if (edge[i].y<topY.y) topY.set(edge[i].x, edge[i].y);
      if (edge[i].y>bottomY.y) bottomY.set(edge[i].x, edge[i].y);
    }
    pushStyle();
    strokeWeight(5);
    stroke(0,255,0);
    point(topY.x, topY.y);
    point(bottomY.x, bottomY.y);
    popStyle();
  }
}
