import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slot_machine/assets.dart';
import 'package:slot_machine/constants/outcome.dart';
import 'package:slot_machine/constants/values.dart';
import 'package:slot_machine/controllers/slot_machine/slot_machine_controller.dart';
import 'package:slot_machine/data/outcomes.dart';
import 'package:slot_machine/data/reel.dart';
import 'package:slot_machine/models/reel_item.dart';
import 'package:slot_machine/models/slot_machine_config.dart';
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

  late final ValueNotifier<double> coins;
  late final ValueNotifier<double> bet;
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

    coins = ValueNotifier(100);
    bet = ValueNotifier(10);

    coins.addListener(() {
      var betValue = bet.value;
      if (betValue > coins.value) {
         betValue = coins.value;
      }
      if (betValue <= 0) {
        betValue = math.min(coins.value, 10);
      }
      bet.value = betValue;
    });
  }

  @override
  void dispose() {
    _bounceControllers.forEach((c) => c.dispose());

    super.dispose();
  }

  Future<void> _spin() async {
    spinning.value = true;
    bettingValue = bet.value.toInt();
    coins.value -= bet.value;
    final result = await _controller.spin(
      onReelStop: (index) => _bounceControllers[index].forward(from: 0),
      targetOutcome: null,
    );
    if (result != null) {
      coins.value += (bet.value * result.multiplier).toInt();
    }
    spinning.value = false;
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
                        valueListenable: coins,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _rollerWidget(
                              context: context,
                              controller: _controller.pageControllers[index],
                              bounceAnimation: _bounceAnimations[index],
                              slots: reelList,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder(
                  valueListenable: spinning,
                  builder: (context, isSpinning, child) {
                    if (isSpinning) {
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
                              'Bet',
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

                    return ValueListenableBuilder(
                      valueListenable: coins,
                      builder: (ctx, coinValue, child) {
                        if (coinValue <= 0) {
                          return SizedBox.shrink();
                        }

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
                              ValueListenableBuilder(
                                valueListenable: bet,
                                builder: (ctx, betValue, child) {
                                  return Row(
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
                                            '${betValue.floor()}',
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
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              ValueListenableBuilder(
                                valueListenable: bet,
                                builder: (ctx, betValue, child) {
                                  return Slider(
                                    min: 1,
                                    max: coinValue.floorToDouble(),
                                    value: betValue.floorToDouble(),
                                    onChanged: (v) => bet.value = v.floorToDouble(),
                                  );
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      bet.value = 1;
                                    },
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: coins,
                                    builder: (ctx, coinValue, child) {
                                      return GestureDetector(
                                        onTap: () => bet.value = coinValue,
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: Text(
                                            '${coinValue.floor()}',
                                            style: TextStyle(
                                              color: colors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  }
                ),
                ValueListenableBuilder(
                  valueListenable: spinning,
                  builder: (context, isSpinning, child) {
                    if (isSpinning) {
                      return SizedBox.shrink();
                    }

                    return ValueListenableBuilder(
                      valueListenable: coins,
                      builder: (context, coinValue, _) {
                        if (coinValue > 0) {
                          return SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Get more coins to continue spinning',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showShopDialog(context),
                                  child: const Text('GET COINS'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
                const SizedBox(height: 24),
                Center(
                  child: ValueListenableBuilder(
                    valueListenable: coins,
                    builder: (ctx, coins, child) {
                      return ValueListenableBuilder(
                        valueListenable: spinning,
                        builder: (ctx, spinning, child) {
                          return SpinButton(
                            onTap: spinning || coins <= 0 ? null : _spin,
                          );
                        }
                      );
                    }
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

  Widget _rollerWidget({
    required BuildContext context,
    required PageController controller,
    required Animation<double> bounceAnimation,
    required List<ReelItem> slots,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: 284,
      width: 104,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: IgnorePointer(
            ignoring: true,
            child: PageView.builder(
              controller: controller,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final item = slots[index % slots.length];

                return AnimatedBuilder(
                  animation: bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                );
              },
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
    Outcome outcomeEnum,
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
            outcomeEnum.name[0].toUpperCase() + outcomeEnum.name.substring(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: getOutcomeColor(outcomeEnum, colors),
            ),
          ),
          Text(
            multiplier == 1 ? '×${multiplier.toInt()}' : '×$multiplier',
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
                            coins.value += freeCoins;
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