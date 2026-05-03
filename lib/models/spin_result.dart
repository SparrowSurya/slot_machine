import 'package:slot_machine/models/outcome_detail.dart';
import 'package:slot_machine/models/triplet.dart';


/// Result of the spin,
class SpinResult {
  final Triplet<int> result;
  final OutcomeDetail detail;

  const SpinResult({
    required this.result,
    required this.detail,
  });
}
