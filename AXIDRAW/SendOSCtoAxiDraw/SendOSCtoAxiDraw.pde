import java.util.List;
import java.util.ArrayList; 
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
ArrayList<PVector> vectors = new ArrayList<PVector>();

void setup() {
  size(600, 400);
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1", 12000);
  
  vectors.add(new PVector(100, 100));
  vectors.add(new PVector(150, 100));
  vectors.add(new PVector(150, 150));
  
  vectors.add(new PVector(0, 0));
  
  vectors.add(new PVector(300, 100));
  vectors.add(new PVector(350, 100));
  vectors.add(new PVector(350, 150));
  
}

void draw() {
}

void mousePressed() {
  
  //Nice to have: Split the list into sublist based on special (0,0) vector
    //See this discussion: https://discourse.processing.org/t/solved-slicing-arraylist/12974/3
    //Or this (I implemented what seems to be bad practise, but who cares?)
  //List<PVector> head = vectors.subList(0,3);
  
  ArrayList<PVector> myHead = new ArrayList(vectors.subList(0, 3));
  println(myHead);
  ArrayList<PVector> myTails = new ArrayList(vectors.subList(4, 7));
  println(myTails);
  sendOsc(myHead);
  sendOsc(myTails);
  
  //ArrayList<PVector> whatever = head;
  //println(head);

  
  //sendOsc(vectors);
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


void sendOsc(int[] _positions) { //most basic stripped down method with array
  OscMessage msg = new OscMessage("/drawVertex");
  msg.add(_positions);
  oscP5.send(msg, dest);
  println("message sent " + msg);
}
