import 'package:flutter/material.dart';
import 'package:slot_machine/models/reel_item.dart';


/// Displays slot machine widget.
class SlotMachineWidget extends StatelessWidget {
  final List<PageController> controllers;
  final List<Animation<double>> animations;
  final List<ReelItem> items;

  const SlotMachineWidget({
    super.key,
    required this.controllers,
    required this.animations,
    required this.items,
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
          children: List.generate(3, (index) {
            final animation = animations[index];

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: IgnorePointer(
                      ignoring: true,
                      child: PageView.builder(
                        controller: controllers[index],
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          final item = items[index % items.length];

                          return AnimatedBuilder(
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
                          );
                        },
                      ),
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