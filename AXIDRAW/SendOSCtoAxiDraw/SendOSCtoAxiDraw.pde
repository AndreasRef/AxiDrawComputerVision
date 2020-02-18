import java.util.List;
import java.util.ArrayList; 
import oscP5.*;
import netP5.*;

IntList breakPoints;
PVector zeroVector = new PVector(0, 0);
OscP5 oscP5;
NetAddress dest;
ArrayList<PVector> vectors = new ArrayList<PVector>();

void setup() {
  size(600, 400);
  surface.setLocation(0, 0);
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 12000);

  breakPoints = new IntList();

  vectors.add(new PVector(0, 0));
  vectors.add(new PVector(100, 100));
  vectors.add(new PVector(150, 100));
  vectors.add(new PVector(150, 150));

  vectors.add(new PVector(0, 0));

  vectors.add(new PVector(300, 100));
  vectors.add(new PVector(350, 100));
  vectors.add(new PVector(350, 150));

  vectors.add(new PVector(0, 0));

  vectors.add(new PVector(400, 200));
  vectors.add(new PVector(450, 200));
  vectors.add(new PVector(450, 250));
}

void draw() {
  
}

void mousePressed() {  
  splitByDelimiterAndSendOSC(vectors);
  //sendOsc(vectors);
}

void sendOsc(ArrayList<PVector> _vectors) { //send from an flexible ArrayList
  if (_vectors.size()>0) {
    OscMessage msg = new OscMessage("/drawVertex");
    for (int i =0; i<_vectors.size(); i++) { //Remember to cast to ints!
      msg.add((int)_vectors.get(i).x);
      msg.add((int)_vectors.get(i).y);
    }
    oscP5.send(msg, dest);
    println("message sent " + msg);
  } else {
    println("vector not containing anything, message not sent");
  }
}


void sendOsc(int[] _positions) { //most basic stripped down method with array
  OscMessage msg = new OscMessage("/drawVertex");
  msg.add(_positions);
  oscP5.send(msg, dest);
  println("message sent " + msg);
}

/*
 Sloppy way of splitting the list into sublist based on special (0,0) vector
 Hopefully I can make it more rouboust, 
 see https://discourse.processing.org/t/splitting-an-arraylist-for-each-pvector-0-0-updated/17883
 */
void splitByDelimiterAndSendOSC(ArrayList<PVector> _vectors) { //send from sublists, split by zeroVector

  //1 find all places to split and store them in breakPoints
  breakPoints.clear();
  for (int i = 0; i<_vectors.size(); i++) {
    if (_vectors.get(i).equals(zeroVector)) {
      breakPoints.append(i);
    }
  }
  if (breakPoints.size() > 0) {
    int lastBreakpoint = 0;
    for (int i = 0; i<breakPoints.size() + 1; i++) { //2 create breakPoints.size()+1 new ArrayLists 
      ArrayList<PVector> mySubList = new ArrayList<PVector>();
      if (i == 0) { //first sublist
        mySubList = new ArrayList(_vectors.subList(i, breakPoints.get(i)));
        lastBreakpoint = breakPoints.get(i);
      } else if (i<breakPoints.size()) { // all middle cases
        println("i " + i + "    " + "breakPoint " + breakPoints.get(i));
        mySubList = new ArrayList(_vectors.subList(lastBreakpoint+1, breakPoints.get(i)));
        lastBreakpoint = breakPoints.get(i);
      } else { //last sublist
        mySubList = new ArrayList(_vectors.subList(lastBreakpoint + 1, _vectors.size()));
        lastBreakpoint = i;
      }
      println("list " + i + ": " + mySubList);
      sendOsc(mySubList);
      mySubList.clear();
    }
  }
}
