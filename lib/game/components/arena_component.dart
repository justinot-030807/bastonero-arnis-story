import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ArenaType {
  purokLupa,
  coveredCourt,
  nationalArena,
}

class ArenaComponent extends PositionComponent {
  ArenaType arenaType;

  ArenaComponent({
    required Vector2 size,
    this.arenaType = ArenaType.purokLupa,
  }) : super(size: size, priority: 0);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (arenaType) {
      case ArenaType.purokLupa:
        _renderPurokLupa(canvas);
        break;
      case ArenaType.coveredCourt:
        _renderCoveredCourt(canvas);
        break;
      case ArenaType.nationalArena:
        _renderNationalArena(canvas);
        break;
    }
  }

  void _renderPurokLupa(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final horizonY = height * 0.42;

    // 1. Tropical afternoon sky
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, horizonY), skyPaint);

    // Warm sun
    final sunPaint = Paint()..color = const Color(0xFFFFE066);
    canvas.drawCircle(Offset(width * 0.8, horizonY * 0.35), 28, sunPaint);

    // Distant mango/coconut silhouettes
    final treePaint = Paint()..color = const Color(0xFF2E6F40);
    for (double x = -10; x < width + 30; x += 45) {
      canvas.drawCircle(Offset(x + 15, horizonY - 12), 22, treePaint);
      canvas.drawCircle(Offset(x + 30, horizonY - 20), 18, treePaint);
    }

    // Bamboo fencing
    final fencePaint = Paint()
      ..color = const Color(0xFFC29B38)
      ..strokeWidth = 3;
    for (double x = 5; x < width; x += 18) {
      canvas.drawLine(Offset(x, horizonY - 18), Offset(x, horizonY), fencePaint);
    }
    canvas.drawLine(Offset(0, horizonY - 10), Offset(width, horizonY - 10), fencePaint);

    // 2. Dirt court ground (Lupa)
    final groundPaint = Paint()..color = const Color(0xFFB57D42);
    canvas.drawRect(Rect.fromLTWH(0, horizonY, width, height - horizonY), groundPaint);

    // Dirt texture patches / dust
    final dustPaint = Paint()..color = const Color(0xFF9E652E);
    for (int i = 0; i < 15; i++) {
      final dx = (i * 73) % width;
      final dy = horizonY + 20 + ((i * 37) % (height - horizonY - 30));
      canvas.drawRect(Rect.fromLTWH(dx, dy, 18, 4), dustPaint);
    }

    // Sparring ring boundary marked with chalk/lime
    final chalkPaint = Paint()
      ..color = const Color(0xFFE8E0D5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 0.5, horizonY + (height - horizonY) * 0.55),
        width: width * 0.82,
        height: (height - horizonY) * 0.65,
      ),
      chalkPaint,
    );

    // Court name banner
    _renderBanner(canvas, 'PUROK BAKBAKAN RING', width * 0.5, 20, const Color(0xFFD97706));
  }

  void _renderCoveredCourt(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final horizonY = height * 0.38;

    // 1. Bleachers & Corrugated Rafters
    final wallPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, horizonY), wallPaint);

    // Steel trusses overhead
    final trussPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2;
    for (double x = 0; x <= width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x + 25, horizonY * 0.5), trussPaint);
      canvas.drawLine(Offset(x + 25, horizonY * 0.5), Offset(x + 50, 0), trussPaint);
    }

    // Bleacher crowd silhouettes
    final crowdPaint = Paint()..color = const Color(0xFF1E293B);
    for (double x = 10; x < width; x += 22) {
      canvas.drawCircle(Offset(x, horizonY - 14), 7, crowdPaint);
      canvas.drawRect(Rect.fromLTWH(x - 6, horizonY - 8, 12, 10), crowdPaint);
    }

    // 2. Concrete Painted Court Floor (Classic Barangay Green)
    final floorPaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawRect(Rect.fromLTWH(0, horizonY, width, height - horizonY), floorPaint);

    // Painted yellow & white court lines
    final linePaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(width * 0.1, horizonY + 20, width * 0.8, height - horizonY - 40),
      linePaint,
    );

    // Center jump circle / Arnis ring
    canvas.drawCircle(
      Offset(width * 0.5, horizonY + (height - horizonY) * 0.5),
      width * 0.22,
      linePaint,
    );

    _renderBanner(canvas, 'BARANGAY COVERED COURT', width * 0.5, 20, const Color(0xFF16A34A));
  }

  void _renderNationalArena(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final horizonY = height * 0.35;

    // 1. Dark professional sports hall with spotlights
    final hallPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, horizonY), hallPaint);

    // Spotlights beaming down
    final spotPaint = Paint()
      ..color = const Color(0x33F8FAFC)
      ..style = PaintingStyle.fill;
    final spotPath1 = Path()
      ..moveTo(width * 0.2, 0)
      ..lineTo(0, horizonY)
      ..lineTo(width * 0.45, horizonY)
      ..close();
    canvas.drawPath(spotPath1, spotPaint);

    final spotPath2 = Path()
      ..moveTo(width * 0.8, 0)
      ..lineTo(width * 0.55, horizonY)
      ..lineTo(width, horizonY)
      ..close();
    canvas.drawPath(spotPath2, spotPaint);

    // 2. Official WEKAF / Palarong Pambansa Dual Mats (Blue outer, Red inner)
    final blueMat = Paint()..color = const Color(0xFF1D4ED8);
    canvas.drawRect(Rect.fromLTWH(0, horizonY, width, height - horizonY), blueMat);

    final redMat = Paint()..color = const Color(0xFFB91C1C);
    canvas.drawRect(
      Rect.fromLTWH(width * 0.12, horizonY + 15, width * 0.76, height - horizonY - 30),
      redMat,
    );

    // Inner White Square boundary
    final whiteLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(width * 0.2, horizonY + 30, width * 0.6, height - horizonY - 60),
      whiteLine,
    );

    _renderBanner(canvas, 'PALARONG PAMBANSA ARENA', width * 0.5, 20, const Color(0xFFDC2626));
  }

  void _renderBanner(Canvas canvas, String title, double cx, double cy, Color tagColor) {
    final bannerPaint = Paint()..color = tagColor;
    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bannerRect = Rect.fromCenter(center: Offset(cx, cy), width: 220, height: 26);
    canvas.drawRect(bannerRect, bannerPaint);
    canvas.drawRect(bannerRect, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}
