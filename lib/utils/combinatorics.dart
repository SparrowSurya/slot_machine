
/// Utility functions for generating permutations (with replacement) of elements.
List<List<T>> permutationsWithReplacement<T>(List<T> elements, int k) {
  List<List<T>> result = [];

  void generate(List<T> current) {
    if (current.length == k) {
      result.add(List.from(current));
      return;
    }

    for (int i = 0; i < elements.length; i++) {
      current.add(elements[i]);
      generate(current);
      current.removeLast();
    }
  }

  generate([]);
  return result;
}
