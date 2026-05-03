import 'package:flutter/material.dart';


class ConditionalAnimator extends StatefulWidget {
  final ValueNotifier<dynamic> notifier;
  final bool Function() isAllowed;

  final Duration duration;
  final Duration gapDuration;
  final Curve curve;
  final Curve reverseCurve;

  final Widget Function(BuildContext, Widget?, double) builder;

  final Widget child;

  final double fromValue;
  final double toValue;

  const ConditionalAnimator({
    super.key,
    required this.notifier,
    required this.isAllowed,
    required this.builder,
    required this.child,
    this.gapDuration = const Duration(milliseconds: 500),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.linear,
    this.reverseCurve = Curves.linear,
    this.fromValue = 0.0,
    this.toValue = 1.0,
  });

  @override
  State<ConditionalAnimator> createState() => _ConditionalAnimatorState();
}

class _ConditionalAnimatorState extends State<ConditionalAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.fromValue,
      upperBound: widget.toValue,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );

    widget.notifier.addListener(_listen);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_listen);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!mounted) return;

    if (!widget.isAllowed() || _isAnimating) return;

    _isAnimating = true;

    try {
      await _controller.forward(from: widget.fromValue);
      await Future.delayed(widget.gapDuration);
      await _controller.reverse(from: widget.toValue);
    } finally {
      _isAnimating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (ctx, child) => widget.builder(ctx, child, _animation.value),
      child: widget.child,
    );
  }
}
