import 'package:slot_machine/constants/luck.dart';
import 'package:slot_machine/models/reel_item.dart';


/// A list of reel items with their corresponding luck values.
const reelList = [
  ReelItem(emoji: '🍒', luck: Luck.low),
  ReelItem(emoji: '🍋', luck: Luck.low),
  ReelItem(emoji: '🌺', luck: Luck.low),
  ReelItem(emoji: '🍑', luck: Luck.normal),
  ReelItem(emoji: '🔔', luck: Luck.normal),
  ReelItem(emoji: '⭐', luck: Luck.high),
  ReelItem(emoji: '💎', luck: Luck.high),
  ReelItem(emoji: '🍀', luck: Luck.jackpot),
  ReelItem(emoji: '🎁', luck: Luck.bonus),
  ReelItem(emoji: '🃏', luck: Luck.wild),
];
