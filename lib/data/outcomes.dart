import 'package:slot_machine/models/outcome_detail.dart';
import 'package:slot_machine/constants/outcome.dart';

/// Defines the possible outcomes of a slot machine spin and their associated details.
final outcomeDetailList = [
    OutcomeDetail(
      outcome: Outcome.lose,
      multiplier: 0,
      weight: 0.69,
    ),
    OutcomeDetail(
      outcome: Outcome.mini,
      multiplier: 0.5,
      weight: 0.12,
    ),
    OutcomeDetail(
      outcome: Outcome.minor,
      multiplier: 1.0,
      weight: 0.08,
    ),
    OutcomeDetail(
      outcome: Outcome.major,
      multiplier: 2.0,
      weight: 0.05,
    ),
    OutcomeDetail(
      outcome: Outcome.grand,
      multiplier: 5.0,
      weight: 0.03,
    ),
    OutcomeDetail(
      outcome: Outcome.bonus,
      multiplier: 7.0,
      weight: 0.02,
    ),
    OutcomeDetail(
      outcome: Outcome.jackpot,
      multiplier: 10.0,
      weight: 0.01,
    ),
  ];