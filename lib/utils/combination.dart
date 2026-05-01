
/// Utility functions for generating combinations (with replacement)of elements.
List<List<T>> combinationsWithReplacement<T>(List<T> elements, int k) {
  List<List<T>> result = [];

  void generate(List<T> current, int start) {
    if (current.length == k) {
      result.add(List.from(current));
      return;
    }

    for (int i = start; i < elements.length; i++) {
      current.add(elements[i]);
      generate(current, i);
      current.removeLast();
    }
  }

  generate([], 0);
  return result;
}
