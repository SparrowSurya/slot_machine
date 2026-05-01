import 'package:slot_machine/constants/luck.dart';
import 'package:slot_machine/controllers/slot_machine/interface.dart';


/// Represents an item on the slot machine reel, associated with a specific [Luck] and an
/// emoji for display.
class ReelItem implements HasLuck<Luck> {
  final String emoji;

  @override
  final Luck luck;

  const ReelItem({
    required this.emoji,
    required this.luck,
  });
}
