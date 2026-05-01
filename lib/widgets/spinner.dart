import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';


/// A colorful spinning widget.
class SpinnerWidget extends StatefulWidget {
  final List<Color>? colors;
  final Duration? staggerDuration;
  final Duration? spinDuration;
  final Curve? spinCurve;
  final Color? backgroundColor;

  const SpinnerWidget({
    super.key,
    this.colors,
    this.staggerDuration,
    this.spinDuration,
    this.spinCurve,
    this.backgroundColor,
  });

  @override
  State<SpinnerWidget> createState() => _SpinnerWidgetState();
}

class _SpinnerWidgetState extends State<SpinnerWidget> {
  late final List<PageController> _controllers;

  final defaultStagger = Duration(milliseconds: 100);
  final defaultSpinDuration = Duration(seconds: 5);
  final List<Color> defaultColors = [
    Color(0xFFCBA6F7),
    Color(0xFFF38BA8),
    Color(0xFFFAB387),
    Color(0xFFF9E2AF),
    Color(0xFFA6E3A1),
    Color(0xFF89DCEB),
    Color(0xFF89B4FA),
    Color(0xFFB4BEFE),
  ];

  late final List<Color> colors;
  late final Duration _stagger;
  late final Duration _spinDuration;
  late final Curve _spinCurve;

  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    colors = widget.colors ?? defaultColors;

    _stagger = widget.staggerDuration ?? defaultStagger;
    _spinDuration = widget.spinDuration ?? defaultSpinDuration;
    _spinCurve = widget.spinCurve ?? Curves.easeInOutCirc;
    _controllers = List.generate(3, (index) => PageController(
      viewportFraction: 1.0,
      initialPage: colors.length + _random.nextInt(colors.length),
    ), growable: false);

    _startLoop();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startLoop() async {
    while (mounted) {
      final futures = <Future>[];

      for (int i = 0; i < _controllers.length; i++) {
        futures.add(_spinWithDelay(_controllers[i], i));
      }
      await Future.wait(futures);
    }
  }

  Future<void> _spinWithDelay(PageController controller, int index) async {
    await Future.delayed(_stagger * index);
    if (!mounted) return;

    final currentPage = controller.page?.round() ?? controller.initialPage;
    await controller.animateToPage(
      currentPage + colors.length * 2 + _random.nextInt(colors.length),
      duration: _spinDuration,
      curve: _spinCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Container(
          height: 48,
          width: 128,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: widget.backgroundColor ?? Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: List.generate(3, (index) {
              return SizedBox(
                height: 48,
                width: 32,
                child: PageView.builder(
                  controller: _controllers[index],
                  scrollDirection: Axis.vertical,
                  itemBuilder: (ctx, pageIndex) {
                    return Container(
                      height: 32,
                      width: 32,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colors[pageIndex % colors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}