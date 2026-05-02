import 'package:flutter/material.dart';


/// Custom spin button widget with raised effect and disabled state handling.
class SpinButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String? text;

  const SpinButton({
    super.key,
    this.text,
    required this.onTap,
  });

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton> {
  bool isPressed = false;

  bool get isEnabled => widget.onTap != null;

  void _onTapDown(_) {
    if (!isEnabled) return;
    setState(() => isPressed = true);
  }

  void _onTapUp(_) {
    if (!isEnabled) return;
    setState(() => isPressed = false);
    widget.onTap?.call();
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
                widget.text ?? 'SPIN',
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
