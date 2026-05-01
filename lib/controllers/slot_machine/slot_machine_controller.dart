import 'package:flutter/material.dart' show PageController, Curves, Curve;
import 'package:slot_machine/constants/luck.dart';
import 'package:slot_machine/constants/outcome.dart';
import 'package:slot_machine/models/slot_machine_config.dart';
import 'package:slot_machine/models/outcome_detail.dart';
import 'interface.dart';


/// Controller for the slot machine, handling the spinning logic and outcome evaluation.
class SlotMachineController<T extends HasLuck> {
  late final List<PageController> pageControllers;
  final SlotMachineConfig<T> config;

  SlotMachineController({
    required this.config,
    List<PageController>? pageControllers,
    double viewportFraction = 1/3,
  }) {
    assert(pageControllers == null || pageControllers.isEmpty);

    Outcome.computeMetadata();

    final initialPages = _randomTarget();
    assert(initialPages != null);

    this.pageControllers = pageControllers ?? List.generate(3, (i) => PageController(
      initialPage: config.reel.length + initialPages![i],
      viewportFraction: viewportFraction,
    ), growable: false);

  }

  /// Generates a random target combination of reel indices based on the desired [OutcomeDetail].
  List<int>? _randomTarget([OutcomeDetail? detail]) {
    detail ??= config.nextOutcome();
    final lucks = Outcome.getMetadata(detail.outcome);
    if (lucks == null) {
      return null;
    }

    final chosen = config.random.nextInt(lucks.length);
    final (l1, l2, l3) = lucks[chosen];
    final reelLength = config.reel.length;

    final target = [l1, l2, l3].map((Luck luck) {
      final items = List
        .generate(reelLength, (i) => (i, config.reel[i]))
        .where((item) => item.$2.luck == luck)
        .map((item) => item.$1)
        .toList(growable: false);

      final index = config.random.nextInt(items.length);
      return items[index];
    }).toList(growable: false);

    return target;
  }


  /// Spins the reels and returns the resulting [OutcomeDetail]. Optionally, a
  /// [targetOutcome] can be specified to force a specific outcome, and an [expectedTarget]
  /// can be provided for testing purposes.
  Future<OutcomeDetail?> spin({
    void Function(int index)? onReelStop,
    Outcome? targetOutcome,
    List<int>? expectedTarget,
  }) async {
    assert(expectedTarget == null || expectedTarget.length == 3);

    late List<int> target;
    OutcomeDetail? detail;

    if (expectedTarget == null) {
      detail = config.nextOutcome(targetOutcome);
      final randomTarget = _randomTarget(detail);
      if (randomTarget == null) return null;
      target = randomTarget;
    } else {
      target = expectedTarget;
    }

    final reelLength = config.reel.length;
    final spins = 45 + config.random.nextInt(reelLength);
    final offset = 10 + config.random.nextInt(reelLength);

    await _spinReels(
      spins: spins,
      offset: offset,
      target: target,
      reelLength: reelLength,
      onReelStop: onReelStop,
    );

    return detail;
  }

  /// Spins the reels with the specified parameters. Each reel will spin for a number of times.
  Future<void> _spinReels({
    required int spins,
    required int offset,
    required List<int> target,
    required int reelLength,
    void Function(int index)? onReelStop,
  }) async {
    await Future.wait(List.generate(3, (index) async {
      await _spinReel(
        controller: pageControllers[index],
        spins: spins + offset * index,
        target: target[index],
        reelLength: reelLength,
      );

      onReelStop?.call(index);
    }, growable: false));
  }


  /// Spins a single reel to the target index with the specified number of spins and offset.
  Future<void> _spinReel({
    required PageController controller,
    required int spins,
    required int target,
    required int reelLength,
    Duration duration = const Duration(milliseconds: 50),
    Curve curve = Curves.linear,
  }) async {
    final page = controller.page!.toInt();
    final destPage = page + spins;
    final requiredSpins = spins + (target + reelLength - destPage % reelLength);

    for (int i=0; i<requiredSpins; i++) {
      final currPage = controller.page?.round();
      if (currPage == null) return Future.value(null);

      await controller.animateToPage(
        currPage+1,
        duration: duration,
        curve: curve,
      );
    }
  }


  /// Shuffles the reels to random positions. Optionally, an [expectedTarget] can be provided
  /// for testing purposes.
  Future<void> shuffle({
    List<int>? expectedTarget,
  }) async {
    final reelLength = config.reel.length;
    final target = expectedTarget ?? List.generate(3, (_) {
      return config.random.nextInt(reelLength*2);
    });

    await _spinReels(
      spins: reelLength + config.random.nextInt(reelLength),
      offset: 0,
      target: target,
      reelLength: reelLength,
    );
  }
}
