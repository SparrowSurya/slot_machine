import 'package:slot_machine/utils/combination.dart';
import 'luck.dart';


/// Defines the outcome of the spin.
enum Outcome {

  /// All are different.
  lose,

  /// Atlest two matches.
  mini,

  /// 3 Matches of [Luck.low].
  minor,

  /// 3 Matches of [Luck.normal].
  major,

  /// 3 Matches of [Luck.high].
  grand,

  /// Bonus matched.
  bonus,

  /// Jackpot.
  jackpot;

  /// Evaluates [Outcome] basedon the [Luck]'s.
  factory Outcome.fromLuck(Luck l1, Luck l2, Luck l3) {

    // Same luck.
    if (l1 == l2 && l2 == l3) {
      return (switch (l1) {
        Luck.low => Outcome.minor,
        Luck.normal => Outcome.major,
        Luck.high => Outcome.grand,
        Luck.bonus => Outcome.bonus,
        Luck.jackpot => Outcome.jackpot,

        // This case should never match.
        Luck.wild => Outcome.jackpot,
      });
    }

    // All different.
    if (l1 != l2 && l2 != l3 && l3 != l1) {
      return Outcome.lose;
    }

    // Atleast two matches and third is wild.
    if (l1 == Luck.wild || l2 == Luck.wild || l3 == Luck.wild) {
      return Outcome.jackpot;
    }

    // Atleast two matches.
    return Outcome.mini;
  }

  static final Map<Outcome, List<(Luck, Luck, Luck)>> _metadata = {};

  static List<(Luck, Luck, Luck)>? getMetadata(Outcome outcome) => _metadata[outcome];

  static void computeMetadata() {
    if (_metadata.isNotEmpty) {
      return;
    }

    final combinations = combinationsWithReplacement(Luck.values, 3);

    // Remove combinations with more than 1 wild, as they are considered bonus.
    combinations.removeWhere((comb) => comb.where((l) => l == Luck.wild).length > 1);

    for (final combination in combinations) {
      final l1 = combination[0];
      final l2 = combination[1];
      final l3 = combination[2];

      final outcome = Outcome.fromLuck(l1, l2, l3);
      _metadata[outcome] = [ ...?_metadata[outcome], (l1, l2, l3)];
    }
  }
}
