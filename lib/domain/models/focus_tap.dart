// lib/domain/models/focus_tap.dart
// Pure Dart model for the training Focus Tap skill mechanic.

enum FocusTapRating {
  miss,
  good,
  perfect,
}

extension FocusTapRatingExt on FocusTapRating {
  String get displayName {
    switch (this) {
      case FocusTapRating.perfect:
        return 'SWAK! PERFECT';
      case FocusTapRating.good:
        return 'ASINTADO! GOOD';
      case FocusTapRating.miss:
        return 'SABLAY! MISS';
    }
  }

  double get bonusMultiplier {
    switch (this) {
      case FocusTapRating.perfect:
        return 0.40; // +40%
      case FocusTapRating.good:
        return 0.25; // +25%
      case FocusTapRating.miss:
        return 0.0;
    }
  }
}

class FocusTapResult {
  final FocusTapRating rating;
  final double position; // 0.0 .. 1.0

  const FocusTapResult({
    required this.rating,
    required this.position,
  });

  /// Evaluates tap position (0.0 to 1.0).
  /// Center [0.45..0.55] = Perfect (+40%)
  /// Green zone [0.35..0.65] = Good (+25%)
  /// Otherwise = Miss
  factory FocusTapResult.evaluate(double pos) {
    final clamped = pos.clamp(0.0, 1.0);
    if (clamped >= 0.45 && clamped <= 0.55) {
      return FocusTapResult(rating: FocusTapRating.perfect, position: clamped);
    } else if (clamped >= 0.35 && clamped <= 0.65) {
      return FocusTapResult(rating: FocusTapRating.good, position: clamped);
    } else {
      return FocusTapResult(rating: FocusTapRating.miss, position: clamped);
    }
  }
}
