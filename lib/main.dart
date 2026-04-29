import 'dart:math' as math;

import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slot Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
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
  static const slots = ['💀', '💥', '🌧️', '😐', '🎯', '🍀', '⭐', '🔥', '💎', '👑'];
  static const count = 3;

  final random = math.Random(0);
  late List<PageController> pageControllers;
  late List<PageController> targetControllers;

  late List<AnimationController> bounceControllers;
  late List<Animation<double>> bounceAnimations;

  final controlledOutput = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    targetControllers = List.generate(count, (_) => PageController(
      initialPage: random.nextInt(slots.length),
      viewportFraction: 1.0,
    ));

    _recreate(initialised: false);
  }

  @override
  void dispose() {
    targetControllers.forEach((c) => c.dispose());
    pageControllers.forEach((c) => c.dispose());
    bounceControllers.forEach((c) => c.dispose());

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MySlotMachine oldWidget) {
    super.didUpdateWidget(oldWidget);

    _recreate(initialised: true);
  }

  void _recreate({bool initialised = false}) {
    if (initialised) {
      pageControllers.forEach((c) => c.dispose());
      bounceControllers.forEach((c) => c.dispose());
    }

    final viewportFraction = 1/3;
    pageControllers = List.generate(count, (_) {
      return PageController(
        initialPage: random.nextInt(slots.length),
        viewportFraction: viewportFraction,
      );
    });

    List<Animation<double>> animations = [];
    bounceControllers = List.generate(count, (_) {
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
    });

    bounceAnimations = animations;
  }

  Future<void> spin() async {
    final controlled = controlledOutput.value;
    final target = controlled
      ? targetControllers.map((c) => c.page!.toInt()).toList()
      : List.generate(count, (_) => 0);
    final times = 45 + random.nextInt(slots.length);
    final offset = 10 + random.nextInt(slots.length);

    await Future.wait(List.generate(count, (index) async {
      final controller = pageControllers[index];
      final page = controller.page!.toInt();
      final estimatedSpins = times + offset * index;
      final destPage = page + estimatedSpins;
      final spins = controlled
        ? estimatedSpins + (target[index] + slots.length - destPage % slots.length)
        : estimatedSpins;

      for (int i=0; i<spins; i++) {
        final currPgae = controller.page?.round();
        if (currPgae == null) return Future.value(null);

        await controller.animateToPage(
          currPgae+1,
          duration: Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      }

      await bounceControllers[index].forward(from: 0);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: List.generate(count, (index) {
                  return _rollerWidget(
                    context: context,
                    controller: pageControllers[index],
                    bounceAnimation: bounceAnimations[index],
                    slots: slots,
                  );
                }).toList(),
              ),
            ),
            OutlinedButton(
              onPressed: spin,
              child: Text(
                'Spin',
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: controlledOutput,
              builder: (context, controlled, child) {
                return GestureDetector(
                  onTap: () => controlledOutput.value = !controlledOutput.value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Icon(
                        controlled ? Icons.check : Icons.close,
                        size: 32,
                        color: Colors.white,
                      ),
                      Text(
                        'Desired Output',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            ValueListenableBuilder(
              valueListenable: controlledOutput,
              builder: (context, controlled, child) {
                if (!controlled) {
                  return SizedBox.shrink();
                }

                return SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: targetControllers.map((controller) {
                      return SizedBox(
                        height: 40,
                        width: 40,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: slots.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (ctx, index) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Text(
                                slots[index],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _rollerWidget({
    required BuildContext context,
    required PageController controller,
    required Animation<double> bounceAnimation,
    required List<String> slots
  }) {
    return Container(
      height: 184,
      width: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: PageView.builder(
              controller: controller,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final emoji = slots[index % slots.length];

                return AnimatedBuilder(
                  animation: bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0),
                    const Color.fromARGB(255, 105, 103, 96),
                    const Color.fromARGB(255, 176, 176, 176).withAlpha(50),
                    const Color.fromARGB(255, 176, 176, 176).withAlpha(50),
                    const Color.fromARGB(255, 105, 103, 96),
                    const Color.fromARGB(255, 0, 0, 0),
                  ],
                  stops: [0.0, 0.1, 0.4, 0.6, 0.9, 1.0],
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
