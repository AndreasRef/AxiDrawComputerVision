// https://Discourse.Processing.org/t/splitting-an-arraylist-for-each-pvector-0-0-updated/17883/11

import java.util.List;
import static java.util.Arrays.binarySearch;
final List<PVector> vecs = new ArrayList<PVector>();
final PVector DELIM_VEC = new PVector(0,0);
List<List<PVector>> vecs2d;

void setup() {
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
  }
  
  exit();
}
