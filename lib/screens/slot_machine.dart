import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:slot_machine/assets.dart';
import 'package:slot_machine/constants/outcome.dart';
import 'package:slot_machine/constants/values.dart';
import 'package:slot_machine/controllers/slot_machine/slot_machine_controller.dart';
import 'package:slot_machine/data/outcomes.dart';
import 'package:slot_machine/data/reel.dart';
import 'package:slot_machine/models/slot_machine_config.dart';
import 'package:slot_machine/widgets/bet_display_widget.dart';
import 'package:slot_machine/widgets/bet_selection_widget.dart';
import 'package:slot_machine/widgets/out_of_coins_widget.dart';
import 'package:slot_machine/widgets/slot_machine_widget.dart';
import 'package:slot_machine/widgets/spin_button.dart';


/// The main slot machine screen widget.
class MySlotMachine extends StatefulWidget {
  const MySlotMachine({super.key});

  @override
  State<MySlotMachine> createState() => _MySlotMachineState();
}

class _MySlotMachineState extends State<MySlotMachine> with TickerProviderStateMixin {
  final random = math.Random();

  late final SlotMachineConfig _config;
  late final SlotMachineController _controller;
  late final List<AnimationController> _bounceControllers;
  late final List<Animation<double>> _bounceAnimations;

  late final ValueNotifier<double> _coinsNotifier;
  late final ValueNotifier<double> _betNotifier;
  late final ValueNotifier<bool> _isFreeSpinNotifier;
  final spinning = ValueNotifier(false);

  int bettingValue = 0;

  @override
  void initState() {
    super.initState();

    List<Animation<double>> animations = [];
    _bounceControllers = List.generate(3, (_) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      final animation = TweenSequence([
        TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: 12.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 12.0,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(controller);

      animations.add(animation);
      return controller;
    }, growable: false);

    _bounceAnimations = List.unmodifiable(animations);

    _config = SlotMachineConfig(
      reel: reelList,
      random: math.Random(),
      outcomes: outcomeDetailList,
    );

    _controller = SlotMachineController(config: _config);

    _coinsNotifier = ValueNotifier(100);
    _betNotifier = ValueNotifier(10);
    _isFreeSpinNotifier = ValueNotifier(false);
    _coinsNotifier.addListener(() {
      var betValue = _betNotifier.value;
      if (betValue > _coinsNotifier.value) {
         betValue = _coinsNotifier.value;
      }
      if (betValue <= 0) {
        betValue = math.min(_coinsNotifier.value, 10);
      }
      _betNotifier.value = betValue;
    });
  }

  @override
  void dispose() {
    _bounceControllers.forEach((c) => c.dispose());

    super.dispose();
  }

  Future<void> _spin() async {
    spinning.value = true;
    bettingValue = _betNotifier.value.toInt();

    final isFreeSpin = _isFreeSpinNotifier.value;
    if (!isFreeSpin) _coinsNotifier.value -= bettingValue;

    final result = await _controller.spin(
      onReelStop: (index) => _bounceControllers[index].forward(from: 0),
      targetOutcome: null,
    );
    if (!mounted) return;

    if (result != null) {
      final earning = (bettingValue * result.multiplier).toInt();
      _coinsNotifier.value += earning;
      if (result.outcome == Outcome.bonus) {
        _isFreeSpinNotifier.value = true;
      }
    }
    spinning.value = false;
    if (isFreeSpin) _isFreeSpinNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              color: theme.scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  spacing: 8,
                  children: [
                    const Spacer(),
                    const Text(
                      'Lucky Spin',
                      style: TextStyle(
                        fontFamily: AppFonts.notoSans,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => _showInfoDialog(context),
                          child: Icon(Icons.info_outline, size: 24, color: colors.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showShopDialog(context),
                      child: Text(
                        '🤑',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _coinsNotifier,
                        builder: (ctx, coinsValue, child) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: coinsValue),
                            duration: const Duration(milliseconds: 500),
                            builder: (ctx, value, child) {
                              return Text(
                                '${value.floorToDouble()}  ${AppConstants.coinEmoji}',
                                style: TextStyle(
                                  color: colors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            }
                          );
                        }
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SlotMachineWidget(
                    controllers: _controller.pageControllers,
                    animations: _bounceAnimations,
                    items: reelList,
                  ),
                ),
                const SizedBox(height: 24),
                const Spacer(),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    spinning,
                    _coinsNotifier,
                    _betNotifier,
                    _isFreeSpinNotifier,
                  ]),
                  builder: (ctx, child) {
                    final isSpinning = spinning.value;
                    final coinValue = _coinsNotifier.value;
                    final betValue = _betNotifier.value;
                    final isFree = _isFreeSpinNotifier.value;

                    Widget? child;

                    if (isSpinning) {
                      child = BetDisplayWidget(
                        currentBet: isFree ? 0 : betValue,
                      );
                    }

                    if (coinValue <= 0 && !isSpinning) {
                      return OutOfCoinsWidget(
                        gotoShop: () => _showShopDialog(context),
                      );
                    }

                    if (coinValue > 0 && !isSpinning) {
                      child = BetSelectionWidget(
                        minBet: 1.0,
                        maxBet: coinValue,
                        currentBet: betValue,
                        onBetChanged: isSpinning ? null : (v) => _betNotifier.value = v,
                      );
                    }

                    return AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: child ?? SizedBox.shrink(),
                    );
                  },
                ),
                const Spacer(),
                const SizedBox(height: 24),
                Center(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([
                      spinning,
                      _coinsNotifier,
                      _isFreeSpinNotifier,
                    ]),
                    builder: (ctx, child) {
                      final isFree = _isFreeSpinNotifier.value;
                      final isSpinning = spinning.value;
                      final coinValue = _coinsNotifier.value;
                      final isEnabled = !isSpinning && coinValue > 0;

                      return SpinButton(
                        text: isFree ? 'FREE' : null,
                        onTap: isEnabled ? _spin : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How to Play',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Spin the reels and match symbols to win coins.\n'
                  'Higher matches give better rewards!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Divider(
                  color: colors.onSurface.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                ...outcomeDetailList
                  .map((o) => _buildOutcomeRow(context, o.outcome, o.multiplier)),
                const SizedBox(height: 12),
                Text(
                  'Results are random. Higher rewards are rarer.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('GOT IT'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutcomeRow(
    BuildContext context,
    Outcome outcome,
    double multiplier,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            outcome.name[0].toUpperCase() + outcome.name.substring(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: getOutcomeColor(outcome, colors),
            ),
          ),
          Text(
            formatMultiplier(multiplier),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showShopDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final random = math.Random();
    final freeCoins = 10 + random.nextInt(91);

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Coin Shop',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🎁 Free Coins',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$freeCoins 🟡',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _coinsNotifier.value += freeCoins;
                            Navigator.pop(context);
                          },
                          child: const Text('CLAIM'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Coin Packs',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                _coinPack(context, coins: 100, price: '₹49'),
                _coinPack(context, coins: 250, price: '₹99'),
                _coinPack(context, coins: 1000, price: '₹299'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _coinPack(
    BuildContext context, {
    required int coins,
    required String price,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Text(
              '$coins 🟡',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {}, // TODO: Implement purchase flow
              child: Text(price),
            ),
          ],
        ),
      ),
    );
  }

  String formatMultiplier(double value) {
    final multiplier = value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
    return "×$multiplier";
  }

  Color getOutcomeColor(Outcome outcomeEnum, ColorScheme colors) {
    switch (outcomeEnum) {
      case Outcome.jackpot:
        return colors.secondary;
      case Outcome.bonus:
        return colors.primary;
      case Outcome.grand:
        return colors.primary.withValues(alpha: 0.8);
      default:
        return colors.onSurface;
    }
  }
}