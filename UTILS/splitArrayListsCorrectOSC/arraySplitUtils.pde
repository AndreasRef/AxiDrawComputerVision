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
