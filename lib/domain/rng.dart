// lib/domain/rng.dart
// Seeded pseudo-random number generator for reproducible matches, training variance, and testing.

import 'dart:math';

class GameRng {
  final Random _rnd;
  final int? seed;

  GameRng([this.seed]) : _rnd = seed != null ? Random(seed) : Random();

  double nextDouble() => _rnd.nextDouble();

  int nextInt(int max) => _rnd.nextInt(max);

  bool nextBool() => _rnd.nextBool();

  /// Returns a double uniformly distributed between [min] and [max].
  double rangeDouble(double min, double max) {
    return min + (max - min) * _rnd.nextDouble();
  }

  /// Returns an integer between [min] and [max] inclusive.
  int rangeInt(int min, int max) {
    return min + _rnd.nextInt(max - min + 1);
  }

  /// Randomly pick an element from a list.
  T pick<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('Cannot pick from empty list');
    return list[_rnd.nextInt(list.length)];
  }
}
