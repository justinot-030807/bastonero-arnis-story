// lib/game/asset_registry.dart
// Image-based asset pipeline.
// Loads PNG sprites from assets/images/ or generates high-visibility colored pixel placeholders if missing.

import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class AssetRegistry {
  static final Map<String, Sprite> _cache = {};

  /// Clears cached sprites (useful during development and reload).
  static void clearCache() {
    _cache.clear();
  }

  /// Loads a sprite from [path] (relative to assets/images/), or returns a colored placeholder.
  static Future<Sprite> sprite(String path, {int width = 24, int height = 32, Color? placeholderColor}) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    try {
      final image = await Flame.images.load(path);
      final sp = Sprite(image);
      _cache[path] = sp;
      return sp;
    } catch (_) {
      // Return procedural colored fallback placeholder so the game never crashes
      final placeholder = await _createPlaceholder(path, width: width, height: height, color: placeholderColor);
      _cache[path] = placeholder;
      return placeholder;
    }
  }

  /// Synchronous retrieval if already cached, otherwise returns fallback.
  static Sprite? getCached(String path) => _cache[path];

  /// Creates a flat-color retro pixel placeholder with a dark outline and label initials.
  static Future<Sprite> _createPlaceholder(
    String path, {
    required int width,
    required int height,
    Color? color,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final w = width.toDouble();
    final h = height.toDouble();

    // Deterministic hue based on path string if not specified
    final bgCol = color ?? _colorFromPath(path);

    // 1. Dark outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), outlinePaint);

    // 2. Main flat pixel fill
    final fillPaint = Paint()
      ..color = bgCol
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(1, 1, w - 2, h - 2), fillPaint);

    // 3. Highlight bevel
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(1, 1, w - 2, 2), highlightPaint);

    // 4. Short label text (filename initials)
    final fileName = path.split('/').last.split('.').first;
    final initials = fileName.length > 3 ? fileName.substring(0, 3).toUpperCase() : fileName.toUpperCase();

    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: const TextStyle(
          color: Color(0xFF1A1C2C),
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);

    textPainter.paint(canvas, Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    return Sprite(img);
  }

  static Color _colorFromPath(String path) {
    if (path.contains('character') || path.contains('body')) return const Color(0xFF38BDF8);
    if (path.contains('equipment')) return const Color(0xFFF4B41B);
    if (path.contains('floor') || path.contains('camp')) return const Color(0xFF8C532B);
    if (path.contains('match') || path.contains('ring')) return const Color(0xFFDC2626);
    if (path.contains('ui')) return const Color(0xFF2563EB);
    return const Color(0xFF4ADE80);
  }

  /// Synchronously draws a placeholder box with dark outline, highlight bevel, and label initials.
  static void drawPlaceholder(
    Canvas canvas,
    Rect rect, {
    required String label,
    required Color color,
    Color outlineColor = const Color(0xFF1A1C2C),
    double fontSize = 8.0,
  }) {
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(rect, outlinePaint);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(rect.deflate(1.5), fillPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(rect.left + 1.5, rect.top + 1.5, rect.width - 3, 2), highlightPaint);

    final display = label.length > 5 ? label.substring(0, 5) : label;
    final tp = TextPainter(
      text: TextSpan(
        text: display,
        style: TextStyle(
          color: outlineColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Silkscreen',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width);

    tp.paint(
      canvas,
      Offset(
        rect.left + (rect.width - tp.width) / 2,
        rect.top + (rect.height - tp.height) / 2,
      ),
    );
  }
}
