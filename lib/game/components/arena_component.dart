import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ArenaType {
  purokLupa,
  coveredCourt,
  nationalArena,
}

class ArenaComponent extends PositionComponent {
  ArenaType arenaType;
  double crowdAnimTimer = 0.0;
  double refereeX = 0.5;
  double refereeDir = 1.0;

  ArenaComponent({
    required Vector2 size,
    this.arenaType = ArenaType.purokLupa,
  }) : super(size: size, priority: 0);

  @override
  void update(double dt) {
    super.update(dt);
    crowdAnimTimer += dt;

    // Referee slowly paces back and forth in the background of the ring
    refereeX += refereeDir * 0.05 * dt;
    if (refereeX > 0.58) refereeDir = -1.0;
    if (refereeX < 0.42) refereeDir = 1.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (arenaType) {
      case ArenaType.purokLupa:
        _render2DPurokLupa(canvas);
        break;
      case ArenaType.coveredCourt:
        _render2DCoveredCourt(canvas);
        break;
      case ArenaType.nationalArena:
        _render2DNationalArena(canvas);
        break;
    }
  }

  void _render2DPurokLupa(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final horizonY = height * 0.40;

    // 1. Tropical afternoon sky & coconut trees
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, horizonY), skyPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFE066);
    canvas.drawRect(Rect.fromLTWH(width * 0.8, horizonY * 0.2, 32, 32), sunPaint);

    // Distant Mango & Coconut Leaves
    final treePaint = Paint()..color = const Color(0xFF2E6F40);
    for (double x = -10; x < width + 30; x += 40) {
      canvas.drawRect(Rect.fromLTWH(x, horizonY - 30, 36, 26), treePaint);
    }

    // 2. Spectator Crowd on Wooden Bleachers (Cheering & Waving Banners)
    _renderSpectatorsAndJudges(canvas, width, horizonY, const Color(0xFF8C532B));

    // 3. 2.5D Isometric Ring Floor (Chalked Sand & Soil)
    final ringPaint = Paint()..color = const Color(0xFFB57D42);
    final ringPath = Path()
      ..moveTo(width * 0.08, horizonY + 20)
      ..lineTo(width * 0.92, horizonY + 20)
      ..lineTo(width * 0.98, height)
      ..lineTo(width * 0.02, height)
      ..close();
    canvas.drawPath(ringPath, ringPaint);

    // Inner White Chalk Sparring Border
    final chalkPaint = Paint()
      ..color = const Color(0xFFF4ECE1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final innerPath = Path()
      ..moveTo(width * 0.18, horizonY + 36)
      ..lineTo(width * 0.82, horizonY + 36)
      ..lineTo(width * 0.88, height - 16)
      ..lineTo(width * 0.12, height - 16)
      ..close();
    canvas.drawPath(innerPath, chalkPaint);

    // 4. Animated Referee in ring
    _renderReferee(canvas, width * refereeX, horizonY + 45);

    // Banner Tag
    _renderRetroBanner(canvas, 'PUROK BAKBAKAN ARENA', width * 0.5, 18, const Color(0xFFE6482E));
  }

  void _render2DCoveredCourt(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final horizonY = height * 0.40;

    // Bleacher Back Wall
    final wallPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, horizonY), wallPaint);

    _renderSpectatorsAndJudges(canvas, width, horizonY, const Color(0xFF1E293B));

    // Concrete Barangay Green Court (2.5D Isometric)
    final floorPaint = Paint()..color = const Color(0xFF15803D);
    final courtPath = Path()
      ..moveTo(width * 0.08, horizonY + 20)
      ..lineTo(width * 0.92, horizonY + 20)
      ..lineTo(width * 0.98, height)
      ..lineTo(width * 0.02, height)
      ..close();
    canvas.drawPath(courtPath, floorPaint);

    // Yellow boundary lines
    final linePaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(width * 0.15, horizonY + 35, width * 0.70, height - horizonY - 50),
      linePaint,
    );

    _renderReferee(canvas, width * refereeX, horizonY + 45);

    _renderRetroBanner(canvas, 'BARANGAY COVERED COURT', width * 0.5, 18, const Color(0xFF16A34A));
  }

  void _render2DNationalArena(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final horizonY = height * 0.38;

    final wallPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, horizonY), wallPaint);

    _renderSpectatorsAndJudges(canvas, width, horizonY, const Color(0xFF1E293B));

    // WEKAF National Competition Mats (Blue Outer, Red Inner)
    final blueMat = Paint()..color = const Color(0xFF1D4ED8);
    final matPath = Path()
      ..moveTo(width * 0.08, horizonY + 20)
      ..lineTo(width * 0.92, horizonY + 20)
      ..lineTo(width * 0.98, height)
      ..lineTo(width * 0.02, height)
      ..close();
    canvas.drawPath(matPath, blueMat);

    final redMat = Paint()..color = const Color(0xFFB91C1C);
    canvas.drawRect(
      Rect.fromLTWH(width * 0.16, horizonY + 35, width * 0.68, height - horizonY - 50),
      redMat,
    );

    _renderReferee(canvas, width * refereeX, horizonY + 45);

    _renderRetroBanner(canvas, 'PALARONG PAMBANSA NATIONAL COLISEUM', width * 0.5, 18, const Color(0xFFDC2626));
  }

  void _renderSpectatorsAndJudges(Canvas canvas, double width, double horizonY, Color benchColor) {
    // Bleachers
    final bench = Paint()..color = benchColor;
    canvas.drawRect(Rect.fromLTWH(0, horizonY - 32, width, 52), bench);

    // Cheering Crowd of Pixel Spectators
    final crowdColors = [
      const Color(0xFFDC2626),
      const Color(0xFFF4B41B),
      const Color(0xFF38BDF8),
      const Color(0xFF4ADE80),
      const Color(0xFFE2E8F0),
    ];

    for (int row = 0; row < 2; row++) {
      final by = horizonY - 26 + (row * 16);
      for (double x = 8; x < width - 10; x += 18) {
        final bounce = sin((crowdAnimTimer * 6) + (x * 0.1) + row) * 2.5;
        final color = crowdColors[(x.toInt() + row) % crowdColors.length];

        final headPaint = Paint()..color = color;
        canvas.drawRect(Rect.fromLTWH(x, by + bounce, 7, 7), headPaint);
        // Head outline
        final outline = Paint()
          ..color = const Color(0xFF1A1C2C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawRect(Rect.fromLTWH(x, by + bounce, 7, 7), outline);

        // Occasional raised banner / pennant
        if ((x.toInt() % 54) == 0) {
          final bannerPaint = Paint()..color = const Color(0xFFFDE047);
          canvas.drawRect(Rect.fromLTWH(x - 2, by + bounce - 9, 12, 6), bannerPaint);
        }
      }
    }

    // 3 Judges Sitting at Ringside Table (Right Corner)
    final tableX = width * 0.74;
    final tableY = horizonY + 12;

    // Judges Table
    final tablePaint = Paint()..color = const Color(0xFF564064);
    canvas.drawRect(Rect.fromLTWH(tableX, tableY, 68, 12), tablePaint);

    // 3 Judges
    for (int j = 0; j < 3; j++) {
      final jx = tableX + 8 + (j * 20);
      final judgeBody = Paint()..color = const Color(0xFF1E293B);
      final judgeHead = Paint()..color = const Color(0xFFF2B880);
      canvas.drawRect(Rect.fromLTWH(jx, tableY - 14, 10, 10), judgeHead);
      canvas.drawRect(Rect.fromLTWH(jx, tableY - 4, 10, 6), judgeBody);
      // Scoreboard paper
      final paper = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(jx + 2, tableY + 2, 6, 5), paper);
    }
  }

  void _renderReferee(Canvas canvas, double rx, double ry) {
    // Official black/white referee shirt
    final refShirt = Paint()..color = const Color(0xFFF4ECE1);
    final refPants = Paint()..color = const Color(0xFF1A1C2C);
    final skin = Paint()..color = const Color(0xFFF2B880);

    // Pants
    canvas.drawRect(Rect.fromLTWH(rx, ry + 12, 10, 14), refPants);
    // Torso with black vertical referee stripes
    canvas.drawRect(Rect.fromLTWH(rx - 1, ry + 4, 12, 10), refShirt);
    final stripe = Paint()..color = const Color(0xFF1A1C2C);
    canvas.drawRect(Rect.fromLTWH(rx + 2, ry + 4, 2, 10), stripe);
    canvas.drawRect(Rect.fromLTWH(rx + 6, ry + 4, 2, 10), stripe);

    // Head
    canvas.drawRect(Rect.fromLTWH(rx + 1, ry - 4, 8, 8), skin);
  }

  void _renderRetroBanner(Canvas canvas, String title, double cx, double cy, Color tagColor) {
    final bannerPaint = Paint()..color = tagColor;
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final bannerRect = Rect.fromCenter(center: Offset(cx, cy), width: 280, height: 24);
    canvas.drawRect(bannerRect, bannerPaint);
    canvas.drawRect(bannerRect, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}
