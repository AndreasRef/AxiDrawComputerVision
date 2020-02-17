import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

int[] positions = new int[8];

ArrayList<PVector> vectors = new ArrayList<PVector>();

void setup() {
  size(600, 400);
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1", 12000);
  
  
  vectors.add(new PVector(100, 100));
  vectors.add(new PVector(150, 100));
  vectors.add(new PVector(150, 150));
  
  positions[0] = 100;
  positions[1] = 100;
  positions[2] = 150;
  positions[3] = 100;
  positions[4] = 150;
  positions[5] = 150;
  positions[6] = 100;
  positions[7] = 100;
}

void draw() {
}

void mousePressed() {
  sendOsc(positions);
}

void sendOsc(ArrayList<PVector> _vectors) { //send from an flexible ArrayList
  OscMessage msg = new OscMessage("/drawVertex");
  for (int i =0; i<_vectors.size(); i++) { //Remember to cast to ints!
    msg.add((int)_vectors.get(i).x);
    msg.add((int)_vectors.get(i).y);
  }
  oscP5.send(msg, dest);
  println("message sent " + msg);
}


void sendOsc(int[] _positions) { //most basic stripped down method
  OscMessage msg = new OscMessage("/drawVertex");
  msg.add(_positions);
  oscP5.send(msg, dest);
  println("message sent " + msg);
}
