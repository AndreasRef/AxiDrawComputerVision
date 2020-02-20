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

static final int[] indicesOf(final List<?> list, final Object object) {
  if (list == null || list.isEmpty())  return new int[0];

  final IntList indices = new IntList();
  final int size = list.size();

  for (int i = 0; i < size; ++i) {
    final Object element = list.get(i);
    if (element != null && element.equals(object))  indices.append(i);
  }

  return indices.array();
}

@SafeVarargs static final <T> List<List<T>>
  splitListAsList2d(final List<T> list, final int... indices) {

  final List<List<T>> list2d = new ArrayList<List<T>>();

  if (list == null || list.isEmpty())  return list2d;

  final int size = list.size(), lastIdx = size - 1;
  final int[] indexes = validateIndices(lastIdx, indices);

  if (indexes.length == 0)  return list2d;

  List<T> list1d = null;
  boolean sequenceGotInterrupted = true;

  for (int i = 0; i < size; ++i) {
    if (binarySearch(indexes, i) >= 0) {
      sequenceGotInterrupted = true;
      continue;
    }

    if (sequenceGotInterrupted) {
      list2d.add(list1d = new ArrayList<T>());
      sequenceGotInterrupted = false;
    }

    list1d.add(list.get(i));
  }

  return list2d;
}

@SafeVarargs static final int[]
  validateIndices(final int maxIndex, final int... indices) {

  if (indices == null || indices.length == 0)  return new int[0];

  final int maxIdx = min(abs(maxIndex), MAX_INT - 3);
  final IntList indexes = new IntList();

  for (final int idx : indices)
    if (idx >= 0 & idx <= maxIdx)  indexes.appendUnique(idx);

  indexes.sort();

  return indexes.array();
}
