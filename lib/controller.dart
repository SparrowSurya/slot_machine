import 'dart:math' as math;

import 'package:flutter/material.dart';


/// Defines the luck of each item.
enum Luck {
  low,
  normal,
  high,
  jackpot,
  bonus,
  wild,
}

/// Defines the outcome of the spin.
enum Outcome {

  /// All are different.
  lose,

  /// Atlest two matches.
  mini,

  /// 3 Matches of [Luck.low].
  minor,

  /// 3 Matches of [Luck.normal].
  major,

  /// 3 Matches of [Luck.high].
  grand,

  /// Bonus matched.
  bonus,

  /// Jackpot.
  jackpot;

  /// Evaluates [Outcome] basedon the [Luck]'s.
  factory Outcome.fromLuck(Luck l1, Luck l2, Luck l3) {
    if (l1 == l2 && l2 == l3) {
      return (switch (l1) {
        Luck.low => Outcome.minor,
        Luck.normal => Outcome.major,
        Luck.high => Outcome.grand,
        Luck.bonus => Outcome.bonus,
        Luck.jackpot => Outcome.jackpot,
        Luck.wild => Outcome.bonus,
      });
    }

    if (l1 != l2 && l2 != l3 && l3 != l1) {
      return Outcome.lose;
    }

    return Outcome.mini;
  }

  static final Map<Outcome, List<(Luck, Luck, Luck)>> _metadata = {};

  static void computeMetadata() {
    final combinations = combinationsWithReplacement(Luck.values, 3);

    // Remove combinations with more than 1 wild, as they are considered bonus.
    combinations.removeWhere((comb) => comb.where((l) => l == Luck.wild).length > 1);

    for (final combination in combinations) {
      final l1 = combination[0];
      final l2 = combination[1];
      final l3 = combination[2];

      final outcome = Outcome.fromLuck(l1, l2, l3);
      _metadata[outcome] = [ ...?_metadata[outcome], (l1, l2, l3)];
    }
  }
}

List<List<T>> combinationsWithReplacement<T>(List<T> elements, int k) {
  List<List<T>> result = [];

  void generate(List<T> current, int start) {
    if (current.length == k) {
      result.add(List.from(current));
      return;
    }

    for (int i = start; i < elements.length; i++) {
      current.add(elements[i]);
      generate(current, i);
      current.removeLast();
    }
  }

  generate([], 0);
  return result;
}

class OutcomeDetail {
  final Outcome outcome;
  final double weight;
  final double multiplier;

  OutcomeDetail({
    required this.outcome,
    required this.weight,
    required this.multiplier,
  });
}


abstract interface class HasLuck<T> {
  T get luck;
}


class SlotMachineConfig<T extends HasLuck> {
  final List<OutcomeDetail> outcomes;
  final math.Random random;
  final List<T> reel;

  SlotMachineConfig({
    required this.reel,
    required this.random,
    required this.outcomes,
  }): assert(outcomes.map((o) => o.weight).reduce((a, b) => a+b) == 100),
      assert(reel.length > 3) {

    outcomes.sort((a, b) => a.weight.compareTo(b.weight));
  }

  OutcomeDetail nextOutcome([Outcome? outcome]) {
    if (outcome != null) {
      return outcomes.firstWhere((o) => o.outcome == outcome);
    }

    final roll = random.nextDouble() * 100;
    var cumulative = 0.0;

    for (final outcome in outcomes) {
      cumulative += outcome.weight;
      if (roll < cumulative) {
        return outcome;
      }
    }

    return outcomes.last;
  }
}

class SlotMachineController<T extends HasLuck> {
  late final List<PageController> pageControllers;
  final SlotMachineConfig<T> config;

  SlotMachineController({
    required this.config,
    List<PageController>? pageControllers,
    double viewportFraction = 1/3,
  }) {
    assert(pageControllers == null || pageControllers.isEmpty);

    if (Outcome._metadata.isEmpty) {
      Outcome.computeMetadata();
    }

    final initialPages = _randomTarget();
    assert(initialPages != null);

    this.pageControllers = pageControllers ?? List.generate(3, (i) => PageController(
      initialPage: config.reel.length + initialPages![i],
      viewportFraction: viewportFraction,
    ), growable: false);

  }

  List<int>? _randomTarget([OutcomeDetail? detail]) {
    detail ??= config.nextOutcome();
    final lucks = Outcome._metadata[detail.outcome];
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
