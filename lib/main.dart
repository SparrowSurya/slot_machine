import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromPalette(Catppuccin.mocha),
      home: const MySlotMachine(),
    );
  }
}


class MySlotMachine extends StatefulWidget {
  const MySlotMachine({super.key});

  @override
  State<MySlotMachine> createState() => _MySlotMachineState();
}

class _MySlotMachineState extends State<MySlotMachine> with TickerProviderStateMixin {
  static const coinEmoji = '🪙';
  final random = math.Random();

  late final SlotMachineConfig _config;
  late final SlotMachineController _controller;
  late final List<AnimationController> _bounceControllers;
  late final List<Animation<double>> _bounceAnimations;

  late final ValueNotifier<double> coins;
  late final ValueNotifier<double> bet;
  final spinning = ValueNotifier(false);

  int bettingValue = 0;

  final items = [
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

  final outcomes = [
    OutcomeDetail(
      outcome: Outcome.lose,
      multiplier: 0,
      weight: 69,
    ),
    OutcomeDetail(
      outcome: Outcome.mini,
      multiplier: 0.2,
      weight: 12,
    ),
    OutcomeDetail(
      outcome: Outcome.minor,
      multiplier: 0.5,
      weight: 08,
    ),
    OutcomeDetail(
      outcome: Outcome.major,
      multiplier: 1.0,
      weight: 05,
    ),
    OutcomeDetail(
      outcome: Outcome.grand,
      multiplier: 5.0,
      weight: 03,
    ),
    OutcomeDetail(
      outcome: Outcome.bonus,
      multiplier: 7.0,
      weight: 02,
    ),
    OutcomeDetail(
      outcome: Outcome.jackpot,
      multiplier: 10.0,
      weight: 01,
    ),
  ];

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
      reel: items,
      random: math.Random(),
      outcomes: outcomes,
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
                            '${value.floorToDouble()}  $coinEmoji',
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
                              slots: items,
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
                              '$coinEmoji $bettingValue',
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
                                          const Text(coinEmoji),
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
                                coinEmoji,
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
                            onSpin: spinning || coins <= 0 ? null : _spin,
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
                ...outcomes
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

class SpinButton extends StatefulWidget {
  final VoidCallback? onSpin;

  const SpinButton({super.key, required this.onSpin});

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton> {
  bool isPressed = false;

  bool get isEnabled => widget.onSpin != null;

  void _onTapDown(_) {
    if (!isEnabled) return;
    setState(() => isPressed = true);
  }

  void _onTapUp(_) {
    if (!isEnabled) return;
    setState(() => isPressed = false);
    widget.onSpin?.call();
  }

  void _onTapCancel() {
    if (!isEnabled) return;
    setState(() => isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final baseColor = isEnabled
        ? colors.primary
        : colors.surface.withValues(alpha: 0.6);

    final textColor = isEnabled
        ? colors.onPrimary
        : colors.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..translateByDouble(0, isEnabled && isPressed ? 6 : 0, 0, 1)
          ..scaleByDouble(1, 0.92, 1, 1),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: isEnabled ? 0.9 : 0.4),
                baseColor.withValues(alpha: isEnabled ? 0.7 : 0.3),
              ],
            ),
            boxShadow: isEnabled
              ? (isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                    ),
                  ])
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
            border: Border.all(
              color: Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.03),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isEnabled) ...[
                Positioned(
                  top: 10,
                  child: Container(
                    width: 50,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              Text(
                'SPIN',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class AppFonts {
  static const roboto = 'Roboto';
  static const notoSans = 'NotoSans';
}


class ReelItem implements HasLuck {
  final String emoji;

  @override
  final Luck luck;

  const ReelItem({
    required this.emoji,
    required this.luck,
  });
}

class AppTheme {
  static ThemeData fromPalette(CatppuccinPalette p, {bool isDark = true}) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: AppFonts.roboto,

      scaffoldBackgroundColor: p.base,

      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,

        primary: p.primary,
        onPrimary: p.base,

        secondary: p.secondary,
        onSecondary: p.base,

        surface: p.surface,
        onSurface: p.text,

        error: Colors.red,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: p.base,
        elevation: 0,
        centerTitle: true,
        foregroundColor: p.text,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: p.text,
        ),
      ),

      textTheme: TextTheme(
        bodyMedium: TextStyle(color: p.text),
        titleMedium: TextStyle(
          color: p.text,
          fontWeight: FontWeight.w600,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.surfaceVariant,
        thumbColor: p.primary,
      ),
    );
  }
}

class CatppuccinPalette {
  final Color base;
  final Color mantle;
  final Color crust;

  final Color surface;
  final Color surfaceVariant;

  final Color text;
  final Color subtext;

  final Color primary;
  final Color secondary;

  const CatppuccinPalette({
    required this.base,
    required this.mantle,
    required this.crust,
    required this.surface,
    required this.surfaceVariant,
    required this.text,
    required this.subtext,
    required this.primary,
    required this.secondary,
  });
}

class Catppuccin {
  static const mocha = CatppuccinPalette(
    base: Color(0xFF1E1E2E),
    mantle: Color(0xFF181825),
    crust: Color(0xFF11111B),

    surface: Color(0xFF313244),
    surfaceVariant: Color(0xFF45475A),

    text: Color(0xFFCDD6F4),
    subtext: Color(0xFFA6ADC8),

    primary: Color(0xFFCBA6F7),
    secondary: Color(0xFFF9E2AF),
  );

    static const macchiato = CatppuccinPalette(
    base: Color(0xFF24273A),
    mantle: Color(0xFF1E2030),
    crust: Color(0xFF181926),

    surface: Color(0xFF363A4F),
    surfaceVariant: Color(0xFF494D64),

    text: Color(0xFFCAD3F5),
    subtext: Color(0xFFA5ADCB),

    primary: Color(0xFFC6A0F6),
    secondary: Color(0xFFEED49F),
  );

    static const frappe = CatppuccinPalette(
    base: Color(0xFF303446),
    mantle: Color(0xFF292C3C),
    crust: Color(0xFF232634),

    surface: Color(0xFF414559),
    surfaceVariant: Color(0xFF51576D),

    text: Color(0xFFC6D0F5),
    subtext: Color(0xFFA5ADCE),

    primary: Color(0xFFCA9EE6),
    secondary: Color(0xFFE5C890),
  );

    static const latte = CatppuccinPalette(
    base: Color(0xFFEFF1F5),
    mantle: Color(0xFFE6E9EF),
    crust: Color(0xFFDCE0E8),

    surface: Color(0xFFCCD0DA),
    surfaceVariant: Color(0xFFBCC0CC),

    text: Color(0xFF4C4F69),
    subtext: Color(0xFF6C6F85),

    primary: Color(0xFF8839EF),
    secondary: Color(0xFFDF8E1D),
  );
}
