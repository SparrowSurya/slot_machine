

class Triplet<T> {
  final T m1;
  final T m2;
  final T m3;

  Triplet(this.m1, this.m2, this.m3);

  factory Triplet.fromIterable(Iterable<T> iterable) {
    assert(iterable.length >= 3);
    return Triplet(
      iterable.elementAt(0),
      iterable.elementAt(1),
      iterable.elementAt(2),
    );
  }

  List<T> toList() => [m1, m2, m3];
}
