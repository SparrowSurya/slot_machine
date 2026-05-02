import 'package:flutter/material.dart';
import 'package:slot_machine/constants/values.dart';


class BetDisplayWidget extends StatelessWidget {
  final double currentBet;

  const BetDisplayWidget({
    super.key,
    required this.currentBet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bettingValue = currentBet.floor().toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            'Bet${currentBet.floor() == 0 ? '(FREE)' : ''}:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colors.primary,
            ),
          ),
          Text(
            '${AppConstants.coinEmoji} $bettingValue',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}