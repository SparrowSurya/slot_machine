import 'package:slot_machine/constants/luck.dart';


/// Defines a reel item associated with some [Luck].
abstract interface class HasLuck {
  Luck get luck;
  String get id;
}
