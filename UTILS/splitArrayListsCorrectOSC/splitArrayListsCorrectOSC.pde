// https://Discourse.Processing.org/t/splitting-an-arraylist-for-each-pvector-0-0-updated/17883/11
import oscP5.*;
import netP5.*;
import java.util.List;
import static java.util.Arrays.binarySearch;

OscP5 oscP5;
NetAddress dest;

final List<PVector> vecs = new ArrayList<PVector>();
final PVector DELIM_VEC = new PVector(0,0);
List<List<PVector>> vecs2d;

void setup() {
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1", 12000);
  
  vecs.add(new PVector(100, 100));
  vecs.add(new PVector(150, 100));
  vecs.add(new PVector(150, 150));
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(300, 100)); 
  vecs.add(DELIM_VEC); 
  vecs.add(new PVector(350, 100)); 
  vecs.add(new PVector(350, 150)); 
  vecs.add(DELIM_VEC);
  
  final int[] delimIndexes = indicesOf(vecs, DELIM_VEC);

  vecs2d = splitListAsList2d(vecs, delimIndexes);

  for (final List<PVector> vecs1d : vecs2d) {
    println(vecs1d); //This is where we get the correct lists..
    sendOsc(vecs1d);
  }
  exit();
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
