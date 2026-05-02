import 'package:flutter/material.dart';
import 'package:slot_machine/constants/values.dart';


/// Widget for selecting bet amount, with a slider and preset buttons.
class BetSelectionWidget extends StatelessWidget {
  final double minBet;
  final double maxBet;
  final double currentBet;
  final ValueChanged<double>? onBetChanged;

  const BetSelectionWidget({
    super.key,
    required this.minBet,
    required this.maxBet,
    required this.currentBet,
    this.onBetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
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
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Text(
                'Bet:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${currentBet.floor()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(AppConstants.coinEmoji),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            min: minBet.floorToDouble(),
            max: maxBet.floorToDouble(),
            value: currentBet.floorToDouble(),
            onChanged: (v) => onBetChanged?.call(v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onBetChanged?.call(minBet),
                child: Text(
                  '${minBet.floor()}',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onBetChanged?.call(maxBet),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '${maxBet.floor()}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}