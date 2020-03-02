// https://Discourse.Processing.org/t/splitting-an-arraylist-for-each-pvector-0-0-updated/17883/11
import oscP5.*;
import netP5.*;
import java.util.List;
import static java.util.Arrays.binarySearch;

OscP5 oscP5;
NetAddress dest;

final PVector DELIM_VEC = new PVector(0, 0);

void setup() {
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 12000);

  List<PVector> vecs = new ArrayList<PVector>();
  vecs.add(new PVector(100, 100));
  vecs.add(new PVector(150, 100));
  vecs.add(new PVector(150, 150));
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(50, 50)); 
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(350, 100)); 
  vecs.add(new PVector(350, 150)); 
  //vecs.add(DELIM_VEC);

  splitListsAndSendOSC(vecs);
  exit();
}

void splitListsAndSendOSC(List<PVector> _vectors) {
  final int[] delimIndexes = indicesOf(_vectors, DELIM_VEC);
  List<List<PVector>> vecs2d = splitListAsList2d(_vectors, delimIndexes);

  if (vecs2d.size() > 0) { //in cases where there is a delimiter
    for (int size = vecs2d.size(), i = 0; i < size; ++i) {
      final List<PVector> vecs1d = vecs2d.get(i);
      println(vecs1d);
      sendOsc(vecs1d);
    }
  } else if (_vectors.size()>1) { //in cases where there is no delimiter
    println(_vectors);
    sendOsc(_vectors);
  }
}

void sendOsc(List<PVector> _vectors) { //send from an flexible ArrayList
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
