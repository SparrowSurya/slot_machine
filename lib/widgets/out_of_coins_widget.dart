import 'package:flutter/material.dart';
import 'package:slot_machine/constants/values.dart';


class OutOfCoinsWidget extends StatelessWidget {
  final void Function()? gotoShop;

  const OutOfCoinsWidget({
    super.key,
    this.gotoShop
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          Text(
            AppConstants.coinEmoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 12),
          Text(
            'Out of Coins',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get more coins to continue spinning',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gotoShop,
              child: const Text('GET COINS'),
            ),
          ),
        ],
      ),
    );
  }
}