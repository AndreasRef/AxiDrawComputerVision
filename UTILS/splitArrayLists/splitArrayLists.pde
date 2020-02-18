IntList breakPoints;
ArrayList<PVector> vectors = new ArrayList<PVector>();

PVector zeroVector = new PVector(0, 0);

void setup() {
  breakPoints = new IntList();

  vectors.add(new PVector(0, 0));
  vectors.add(new PVector(100, 100));
  vectors.add(new PVector(150, 100));
  vectors.add(new PVector(150, 150));

  vectors.add(new PVector(0, 0));

  vectors.add(new PVector(300, 100));

  vectors.add(new PVector(0, 0));

  vectors.add(new PVector(350, 100));
  
  vectors.add(new PVector(0, 0));
  
  vectors.add(new PVector(350, 150));
  
  vectors.add(new PVector(0, 0));


  //1 find all places to split and store them in breakPoints
  for (int i = 0; i<vectors.size(); i++) {
    if (vectors.get(i).equals(zeroVector)) {
      breakPoints.append(i);
    }
  }

  //This seems to work unless you place two zeroVectors next to each other or have zeroVectors in the beginning or end
  println(breakPoints.size());

  if (breakPoints.size() > 0) {
    int lastBreakpoint = 0;
    for (int i = 0; i<breakPoints.size() + 1; i++) { //2 create breakPoints.size()+1 new ArrayLists 
      ArrayList<PVector> mySubList = new ArrayList();
      if (i == 0) { //first sublist
        mySubList = new ArrayList(vectors.subList(i, breakPoints.get(i)));
        lastBreakpoint = breakPoints.get(i);
        
      } else if (i<breakPoints.size()) { // all middle cases
        mySubList = new ArrayList(vectors.subList(lastBreakpoint+1, breakPoints.get(i)));
        lastBreakpoint = breakPoints.get(i);
      } else { //last sublist
        mySubList = new ArrayList(vectors.subList(lastBreakpoint + 1, vectors.size()));
      }
      println("list " + i + ": " + mySubList);
    } 
  }
}
