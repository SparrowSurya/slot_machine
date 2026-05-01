import 'package:slot_machine/constants/outcome.dart';


/// Defines the detail of an [Outcome].
class OutcomeDetail {

  /// [Outcome] value.
  final Outcome outcome;

  /// Probability weight of the outcome, out of 100.
  final double weight;

  /// Multiplier for the payout.
  final double multiplier;

  OutcomeDetail({
    required this.outcome,
    required this.weight,
    required this.multiplier,
  });
}