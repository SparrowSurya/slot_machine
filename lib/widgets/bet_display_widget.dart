import 'package:flutter/material.dart';
import 'package:slot_machine/constants/values.dart';


class BetDisplayWidget extends StatelessWidget {
  final double currentBet;
  final bool freeSpin;

  const BetDisplayWidget({
    super.key,
    required this.currentBet,
    this.freeSpin = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bettingValue = currentBet.floor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: freeSpin
              ? colors.primary.withValues(alpha: 0.6) // 👈 highlight in free spin
              : colors.outline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            freeSpin ? "FREE SPIN" : "BET",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: freeSpin
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${AppConstants.coinEmoji} $bettingValue",
            style: TextStyle(
              fontSize: freeSpin ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: freeSpin
                  ? colors.primary
                  : colors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}