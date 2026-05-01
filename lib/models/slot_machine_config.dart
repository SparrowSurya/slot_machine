import 'dart:math' as math;
import 'package:slot_machine/constants/outcome.dart';
import 'package:slot_machine/controllers/slot_machine/interface.dart';
import 'package:slot_machine/models/outcome_detail.dart';


class SlotMachineConfig<T extends HasLuck> {

  /// List of possible outcomes with their details.
  final List<OutcomeDetail> outcomes;

  /// Random number generator for the slot machine.
  final math.Random random;

  /// List of items on the reel, each associated with some [Luck].
  final List<T> reel;

  SlotMachineConfig({
    required this.reel,
    required this.random,
    required this.outcomes,
  }): assert(outcomes.map((o) => o.weight).reduce((a, b) => a+b) == 100),
      assert(reel.length > 3) {

    outcomes.sort((a, b) => a.weight.compareTo(b.weight));
  }

  /// Gets the next [OutcomeDetail] based on the defined probabilities.
  OutcomeDetail nextOutcome([Outcome? outcome]) {
    if (outcome != null) {
      return outcomes.firstWhere((o) => o.outcome == outcome);
    }

    final roll = random.nextDouble() * 100;
    var cumulative = 0.0;

    for (final outcome in outcomes) {
      cumulative += outcome.weight;
      if (roll < cumulative) {
        return outcome;
      }
    }

    return outcomes.last;
  }
}