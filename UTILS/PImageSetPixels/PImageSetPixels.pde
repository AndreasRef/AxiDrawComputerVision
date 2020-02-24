PImage tower;
PImage white;

void setup() {
  size(100, 100);
  tower = loadImage("tower.png");
  white = loadImage("white.png");
  white.resize(50,50); 
  tower.set(30, 20, white); 
}

void draw() {
  image(tower, 0, 0);
}
