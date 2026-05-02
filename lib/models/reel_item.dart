import 'package:slot_machine/constants/luck.dart';
import 'package:slot_machine/controllers/slot_machine/interface.dart';


/// Represents an item on the slot machine reel, associated with a specific [Luck] and an
/// emoji for display.
class ReelItem implements HasLuck {
  final String emoji;

  @override
  final Luck luck;

  const ReelItem({
    required this.emoji,
    required this.luck,
  });

  @override
  String get id => emoji;

  @override
  bool operator ==(Object other) {
    if (other is! ReelItem) return false;
    if (identical(this, other)) return true;
    return emoji == other.emoji && luck == other.luck;
  }

  @override
  int get hashCode => Object.hash(emoji, luck);

  @override
  String toString() => 'ReelItem(emoji: $emoji, luck: ${luck.name})';
}
