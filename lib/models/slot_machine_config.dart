import 'dart:math' as math;
import 'package:slot_machine/constants/luck.dart';
import 'package:slot_machine/constants/outcome.dart';
import 'package:slot_machine/controllers/slot_machine/interface.dart';
import 'package:slot_machine/models/outcome_detail.dart';
import 'package:slot_machine/utils/combinatorics.dart';


class SlotMachineConfig<T extends HasLuck> {

  /// List of possible outcomes with their details.
  final List<OutcomeDetail> outcomes;

  /// Random number generator for the slot machine.
  final math.Random random;

  /// List of items on the reel, each associated with some [Luck].
  final List<T> reel;

  /// Metadata mapping each [Outcome] to the corresponding combinations of reel items.
  final Map<Outcome, List<(T, T, T)>> metadata = {};

  SlotMachineConfig({
    required this.reel,
    required this.random,
    required this.outcomes,
  }): assert(outcomes.map((o) => o.weight).reduce((a, b) => a+b) == 1.0),
      assert(reel.length > 3) {
    _createMetadata();
    outcomes.sort((a, b) => a.weight.compareTo(b.weight));
  }

  /// Gets the next [OutcomeDetail] based on the defined probabilities.
  OutcomeDetail nextOutcome([Outcome? outcome]) {
    if (outcome != null) {
      return outcomes.firstWhere((o) => o.outcome == outcome);
    }

    final roll = random.nextDouble();
    var cumulative = 0.0;

    for (final outcome in outcomes) {
      cumulative += outcome.weight;
      if (roll < cumulative) {
        return outcome;
      }
    }

    return outcomes.last;
  }

  /// Creates metadata.
  void _createMetadata() {
    if (metadata.isNotEmpty) return;

    final combinations = permutationsWithReplacement(reel, 3);

    // Remove combinations with more than 1 wild, as they are considered bonus.
    combinations.removeWhere((comb) => comb.where((l) => l.luck == Luck.wild).length > 1);

    for (final combination in combinations) {
      final l1 = combination[0];
      final l2 = combination[1];
      final l3 = combination[2];

      final outcome = evaluateOutcome(l1, l2, l3);
      metadata[outcome] = [ ...?metadata[outcome], (l1, l2, l3)];
    }
  }

  /// Evaluates the [Outcome] based on the provided list of items.
  Outcome evaluateOutcome(T i1, T i2, T i3) {
    final ids = <String>{i1.id, i2.id, i3.id};
    final lucks = <Luck>{i1.luck, i2.luck, i3.luck};

    // All three same symbols or two same symbols with third one wild.
    if (ids.length == 1 || (ids.length == 2 && lucks.contains(Luck.wild))) {
      final item = [i1, i2, i3].firstWhere((i) => i.luck != Luck.wild);
      return (switch (item.luck) {
        Luck.low => Outcome.minor,
        Luck.normal => Outcome.major,
        Luck.high => Outcome.grand,
        Luck.bonus => Outcome.bonus,
        Luck.jackpot => Outcome.jackpot,

        // This case should never match.
        _ => Outcome.jackpot,
      });
    }

    // Three different symbols.
    if (ids.length == 3) {
      return Outcome.lose;
    }

    // Two similar symbols.
    return Outcome.mini;
  }
}