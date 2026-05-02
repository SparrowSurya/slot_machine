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
  jackpot,
}
