import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:slot_machine/constants/outcome.dart';
import 'package:slot_machine/models/reel_item.dart';
import 'package:slot_machine/models/spin_result.dart';
import 'package:slot_machine/widgets/conditional_animator.dart';


/// Displays slot machine widget.
class SlotMachineWidget<T> extends StatelessWidget {
  final List<PageController> controllers;
  final List<Animation<double>> animations;
  final List<ReelItem> items;
  final ValueNotifier<SpinResult> spinResult;
  final bool spinning;

  const SlotMachineWidget({
    super.key,
    required this.controllers,
    required this.animations,
    required this.items,
    required this.spinResult,
    required this.spinning,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
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
          children: List.generate(3, (reelIndex) {
            final animation = animations[reelIndex];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
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
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IgnorePointer(
                    ignoring: true,
                    child: PageView.builder(
                      controller: controllers[reelIndex],
                      scrollDirection: Axis.vertical,
                      clipBehavior: spinning ? Clip.hardEdge : Clip.none,
                      itemBuilder: (context, index) {
                        index %= items.length;
                        final item = items[index];

                        return ConditionalAnimator(
                          notifier: spinResult,
                          gapDuration: (switch (spinResult.value.detail.outcome) {
                            Outcome.lose => Duration.zero,
                            Outcome.mini => const Duration(milliseconds: 120),
                            Outcome.minor => const Duration(milliseconds: 220),
                            Outcome.major => const Duration(milliseconds: 350),
                            Outcome.grand => const Duration(milliseconds: 600),
                            Outcome.bonus => const Duration(milliseconds: 800),
                            Outcome.jackpot => const Duration(milliseconds: 1400),
                          }),
                          duration: (switch (spinResult.value.detail.outcome) {
                            Outcome.lose => const Duration(milliseconds: 150),
                            Outcome.mini => const Duration(milliseconds: 200),
                            Outcome.minor => const Duration(milliseconds: 250),
                            Outcome.major => const Duration(milliseconds: 300),
                            Outcome.grand => const Duration(milliseconds: 400),
                            Outcome.bonus => const Duration(milliseconds: 450),
                            Outcome.jackpot => const Duration(milliseconds: 600),
                          }),
                          curve: (switch (spinResult.value.detail.outcome) {
                            Outcome.lose => Curves.linear,
                            Outcome.mini => Curves.easeOut,
                            Outcome.minor => Curves.easeOutBack,
                            Outcome.major => Curves.easeOutCubic,
                            Outcome.grand => Curves.elasticOut,
                            Outcome.bonus => Curves.easeInOut,
                            Outcome.jackpot => Curves.elasticOut,
                          }),
                          reverseCurve: (switch (spinResult.value.detail.outcome) {
                            Outcome.lose => Curves.linear,
                            Outcome.mini => Curves.easeIn,
                            Outcome.minor => Curves.easeInOut,
                            Outcome.major => Curves.easeInOutCubic,
                            Outcome.grand => Curves.easeInOut,
                            Outcome.bonus => Curves.easeInOut,
                            Outcome.jackpot => Curves.easeInOutCubic,
                          }),
                          isAllowed: () {
                            final indicies = spinResult.value.result.toList();
                            return indicies[reelIndex] == index;
                          },
                          builder: (ctx, child, value) {
                            return (switch (spinResult.value.detail.outcome) {
                              Outcome.lose => Opacity(
                                opacity: 1 - value * 0.3,
                                child: child,
                              ),
                              Outcome.mini => Transform.scale(
                                scale: 1.0 + value * 0.1,
                                child: child,
                              ),
                              Outcome.minor => Transform.scale(
                                scale: 1.0 + value * 0.2,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withValues(alpha: value * 0.5),
                                        blurRadius: 12 * value,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                ),
                              ),
                              Outcome.major => Transform.rotate(
                                angle: value * 0.2,
                                child: Transform.scale(
                                  scale: 1.0 + value * 0.3,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: value * 0.6),
                                          blurRadius: 18 * value,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  ),
                                ),
                              ),
                              Outcome.grand => Transform.scale(
                                scale: 1.0 + value * 0.5,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withValues(alpha: value * 0.7),
                                        blurRadius: 25 * value,
                                      ),
                                      BoxShadow(
                                        color: Colors.purpleAccent.withValues(alpha: value * 0.4),
                                        blurRadius: 40 * value,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                ),
                              ),
                              Outcome.bonus => Transform.rotate(
                                angle: value * 2 * 3.1416,
                                child: Transform.scale(
                                  scale: 1.0 + value * 0.4,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withValues(alpha: value * 0.7),
                                          blurRadius: 25 * value,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  ),
                                ),
                              ),
                              Outcome.jackpot => Stack(
                                alignment: Alignment.center,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: value),
                                          blurRadius: 30 * value,
                                        ),
                                        BoxShadow(
                                          color: Colors.orange.withValues(alpha: value * 0.6),
                                          blurRadius: 60 * value,
                                        ),
                                      ],
                                    ),
                                    child: const SizedBox(width: 80, height: 80),
                                  ),
                                  ...List.generate(6, (i) {
                                    final angle = (2 * 3.1416 / 6) * i;
                                    final radius = 30 * value;

                                    return Transform.translate(
                                      offset: Offset(
                                        math.cos(angle) * radius,
                                        math.sin(angle) * radius,
                                      ),
                                      child: Opacity(
                                        opacity: 1 - value,
                                        child: const Text("✨", style: TextStyle(fontSize: 12)),
                                      ),
                                    );
                                  }),

                                  // 🎯 main item
                                  Transform.scale(
                                    scale: 1.0 + value,
                                    child: child,
                                  ),
                                ],
                              ),
                            });
                          },
                          child: AnimatedBuilder(
                            key: ValueKey(item.emoji),
                            animation: animation,
                            builder: (ctx, child) {
                              return Transform.translate(
                                offset: Offset(0, animation.value),
                                child: child,
                              );
                            },
                            child: Center(
                              child: Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}