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

    // Referee slowly paces back and forth along the upper floor of the ring
    refereeX += refereeDir * 0.04 * dt;
    if (refereeX > 0.56) refereeDir = -1.0;
    if (refereeX < 0.44) refereeDir = 1.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (arenaType) {
      case ArenaType.purokLupa:
        _renderIsometricArena(
          canvas,
          skyColor: const Color(0xFF87CEEB),
          wallColor: const Color(0xFF6B4226),
          floorColor: const Color(0xFFB57D42),
          innerMatColor: const Color(0xFFC89357),
          matLogo: 'BASTONERO',
          bannerTitle: 'PUROK BAKBAKAN DIAMOND RING',
          bannerColor: const Color(0xFFE6482E),
        );
        break;
      case ArenaType.coveredCourt:
        _renderIsometricArena(
          canvas,
          skyColor: const Color(0xFF1E293B),
          wallColor: const Color(0xFF334155),
          floorColor: const Color(0xFF0F766E),
          innerMatColor: const Color(0xFF14B8A6),
          matLogo: 'BASTONERO',
          bannerTitle: 'BARANGAY COVERED COURT COLISEUM',
          bannerColor: const Color(0xFF0284C7),
        );
        break;
      case ArenaType.nationalArena:
        _renderIsometricArena(
          canvas,
          skyColor: const Color(0xFF0F172A),
          wallColor: const Color(0xFF1E293B),
          floorColor: const Color(0xFF1D4ED8),
          innerMatColor: const Color(0xFF38BDF8),
          matLogo: 'BASTONERO',
          bannerTitle: 'PALARONG PAMBANSA NATIONAL ARENA',
          bannerColor: const Color(0xFFDC2626),
        );
        break;
    }
  }

  void _renderIsometricArena(
    Canvas canvas, {
    required Color skyColor,
    required Color wallColor,
    required Color floorColor,
    required Color innerMatColor,
    required String matLogo,
    required String bannerTitle,
    required Color bannerColor,
  }) {
    final width = size.x;
    final height = size.y;

    // In mobile portrait, top HUD takes ~85px, bottom HUD takes ~215px
    final topBound = 85.0;
    final bottomBound = height - 215.0;
    final arenaCenterY = topBound + (bottomBound - topBound) * 0.50;
    final arenaCenterX = width * 0.5;

    // Kairosoft 2:1 isometric diamond ring proportions
    final ringHalfW = min(width * 0.44, 160.0);
    final ringHalfH = ringHalfW * 0.52; // ~83px

    final ringTop = Offset(arenaCenterX, arenaCenterY - ringHalfH);
    final ringBottom = Offset(arenaCenterX, arenaCenterY + ringHalfH);
    final ringLeft = Offset(arenaCenterX - ringHalfW, arenaCenterY);
    final ringRight = Offset(arenaCenterX + ringHalfW, arenaCenterY);

    // 1. BACKGROUND WALL / SKY
    final bgPaint = Paint()..color = skyColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // 2. STADIUM BLEACHERS & CHEERING AUDIENCE (IMAGE 4 CROWD ROWS)
    _renderStadiumAudience(canvas, width, topBound, ringTop.dy + 8, wallColor);

    // Surrounding ground
    final groundPaint = Paint()..color = wallColor.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(0, ringTop.dy, width, height - ringTop.dy), groundPaint);

    // 3. 2.5D ISOMETRIC DIAMOND RING (IMAGE 4 & 5 ACCURATE GEOMETRY)
    // Platform Apron Base (Isometric 3D Depth underneath)
    final apronHeight = 16.0;
    final apronPaint = Paint()..color = const Color(0xFF1A1C2C);
    final apronPath = Path()
      ..moveTo(ringLeft.dx, ringLeft.dy)
      ..lineTo(ringBottom.dx, ringBottom.dy)
      ..lineTo(ringRight.dx, ringRight.dy)
      ..lineTo(ringRight.dx, ringRight.dy + apronHeight)
      ..lineTo(ringBottom.dx, ringBottom.dy + apronHeight)
      ..lineTo(ringLeft.dx, ringLeft.dy + apronHeight)
      ..close();
    canvas.drawPath(apronPath, apronPaint);

    // Outer Ring Mat (Diamond Rhombus)
    final outerRingPath = Path()
      ..moveTo(ringTop.dx, ringTop.dy)
      ..lineTo(ringRight.dx, ringRight.dy)
      ..lineTo(ringBottom.dx, ringBottom.dy)
      ..lineTo(ringLeft.dx, ringLeft.dy)
      ..close();
    final outerMatPaint = Paint()..color = floorColor;
    canvas.drawPath(outerRingPath, outerMatPaint);

    // Inner Canvas Mat (Contrasting Center Diamond)
    final innerTop = Offset(arenaCenterX, ringTop.dy + 12);
    final innerLeft = Offset(ringLeft.dx + 22, ringLeft.dy);
    final innerRight = Offset(ringRight.dx - 22, ringRight.dy);
    final innerBottom = Offset(arenaCenterX, ringBottom.dy - 12);

    final innerMatPath = Path()
      ..moveTo(innerTop.dx, innerTop.dy)
      ..lineTo(innerRight.dx, innerRight.dy)
      ..lineTo(innerBottom.dx, innerBottom.dy)
      ..lineTo(innerLeft.dx, innerLeft.dy)
      ..close();
    final innerMatPaint = Paint()..color = innerMatColor;
    canvas.drawPath(innerMatPath, innerMatPaint);

    // White Border Lines on Canvas
    final borderPaint = Paint()
      ..color = const Color(0xFFF4ECE1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(innerMatPath, borderPaint);

    // 4. RETRO "BASTONERO" CENTER MAT LOGO (IMAGE 4 EMULATION)
    _renderCenterMatLogo(canvas, arenaCenterX, arenaCenterY - 4, matLogo);

    // 5. 3-TIER RING ROPES & 4 CORNER TURNBUCKLES
    _renderIsometricRopesAndTurnbuckles(
      canvas,
      ringTop: ringTop,
      ringLeft: ringLeft,
      ringRight: ringRight,
      ringBottom: ringBottom,
    );

    // 6. ANIMATED IN-RING REFEREE
    _renderReferee(canvas, arenaCenterX + (refereeX - 0.5) * 70, arenaCenterY - ringHalfH * 0.40);

    // 7. RINGSIDE OFFICIALS / 3 SEATED JUDGES
    _renderRingsideJudges(canvas, width, arenaCenterX, ringBottom.dy + 14);

    // 8. TOP ARENA RETRO BANNER
    _renderRetroBanner(canvas, bannerTitle, arenaCenterX, topBound + 12, bannerColor);
  }

  void _renderCenterMatLogo(Canvas canvas, double cx, double cy, String text) {
    // Pixel-embossed center arena logo
    final tpShadow = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.25),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 4.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tpShadow.layout();
    tpShadow.paint(canvas, Offset(cx - tpShadow.width / 2 + 2, cy - tpShadow.height / 2 + 2));

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFF4ECE1),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 4.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _renderIsometricRopesAndTurnbuckles(
    Canvas canvas, {
    required Offset ringTop,
    required Offset ringLeft,
    required Offset ringRight,
    required Offset ringBottom,
  }) {
    const postHeight = 36.0;

    // Corner Posts Coordinates
    final pTop = ringTop;
    final pLeft = ringLeft;
    final pRight = ringRight;
    final pBottom = ringBottom;

    // 3 Ropes Elevation Offsets (Bottom to Top)
    final ropeOffsets = [10.0, 20.0, 30.0];

    // Ropes Colors (Red / White / Blue)
    final ropePaints = [
      Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
      Paint()
        ..color = const Color(0xFFF4ECE1)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    ];

    for (int r = 0; r < 3; r++) {
      final h = ropeOffsets[r];
      final rPaint = ropePaints[r];

      // Upper back ropes
      canvas.drawLine(
        Offset(pLeft.dx, pLeft.dy - h),
        Offset(pTop.dx, pTop.dy - h),
        rPaint,
      );
      canvas.drawLine(
        Offset(pTop.dx, pTop.dy - h),
        Offset(pRight.dx, pRight.dy - h),
        rPaint,
      );

      // Lower front ropes
      canvas.drawLine(
        Offset(pLeft.dx, pLeft.dy - h),
        Offset(pBottom.dx, pBottom.dy - h),
        rPaint,
      );
      canvas.drawLine(
        Offset(pRight.dx, pRight.dy - h),
        Offset(pBottom.dx, pBottom.dy - h),
        rPaint,
      );
    }

    // 4 Corner Turnbuckle Posts & Cushions
    // 1. Back/Top Post (Neutral White)
    _renderTurnbucklePost(canvas, pTop.dx, pTop.dy, postHeight, const Color(0xFFE2E8F0));

    // 2. Left Post (Blue Corner)
    _renderTurnbucklePost(canvas, pLeft.dx, pLeft.dy, postHeight, const Color(0xFF2563EB));

    // 3. Right Post (Red Corner)
    _renderTurnbucklePost(canvas, pRight.dx, pRight.dy, postHeight, const Color(0xFFDC2626));

    // 4. Front/Bottom Post (Neutral White)
    _renderTurnbucklePost(canvas, pBottom.dx, pBottom.dy, postHeight, const Color(0xFFE2E8F0));
  }

  void _renderTurnbucklePost(Canvas canvas, double px, double py, double height, Color padColor) {
    // Metal post pole
    final polePaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(px, py), Offset(px, py - height), polePaint);

    // Padding cushion
    final padPaint = Paint()..color = padColor;
    final padBorder = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final padRect = Rect.fromCenter(center: Offset(px, py - height + 10), width: 10, height: 20);
    canvas.drawRect(padRect, padPaint);
    canvas.drawRect(padRect, padBorder);
  }

  void _renderStadiumAudience(Canvas canvas, double width, double topY, double bottomY, Color benchColor) {
    // Stadium Bleachers Steps
    final bench = Paint()..color = benchColor;
    canvas.drawRect(Rect.fromLTWH(0, topY, width, max(30.0, bottomY - topY)), bench);

    final crowdColors = [
      const Color(0xFFDC2626), // Red
      const Color(0xFFF4B41B), // Gold
      const Color(0xFF38BDF8), // Cyan
      const Color(0xFF4ADE80), // Green
      const Color(0xFFE2E8F0), // White
      const Color(0xFF8C532B), // Brown
      const Color(0xFF8B5CF6), // Purple
    ];

    final crowdHeight = max(20.0, bottomY - topY - 10.0);
    final rowCount = (crowdHeight / 16.0).floor().clamp(2, 4);

    // Dense Rows of Spectators (Image 4 Art Style)
    for (int row = 0; row < rowCount; row++) {
      final by = topY + 6.0 + (row * 15.0);
      for (double x = 6; x < width - 10; x += 15) {
        final bounce = sin((crowdAnimTimer * 6.5) + (x * 0.15) + (row * 1.5)) * 2.0;
        final color = crowdColors[(x.toInt() + (row * 3)) % crowdColors.length];

        // Head
        final headPaint = Paint()..color = const Color(0xFFF2B880);
        canvas.drawRect(Rect.fromLTWH(x, by + bounce, 7, 7), headPaint);

        // Hair / Cap
        final hairPaint = Paint()..color = color;
        canvas.drawRect(Rect.fromLTWH(x, by + bounce - 2, 7, 3), hairPaint);

        // Body / Shirt
        final shirtPaint = Paint()..color = color;
        canvas.drawRect(Rect.fromLTWH(x - 1, by + bounce + 7, 9, 6), shirtPaint);

        // Black outline for retro pixel style
        final outline = Paint()
          ..color = const Color(0xFF1A1C2C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRect(Rect.fromLTWH(x, by + bounce, 7, 7), outline);

        // Occasional cheering arms raised / banners
        if ((x.toInt() % 45) == 0) {
          final bannerPaint = Paint()..color = const Color(0xFFFDE047);
          canvas.drawRect(Rect.fromLTWH(x - 3, by + bounce - 10, 14, 6), bannerPaint);
          final bannerBorder = Paint()
            ..color = const Color(0xFF1A1C2C)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRect(Rect.fromLTWH(x - 3, by + bounce - 10, 14, 6), bannerBorder);
        }
      }
    }
  }

  void _renderRingsideJudges(Canvas canvas, double width, double centerX, double tableY) {
    final tableX = centerX - 44.0;

    // Judges Table
    final tablePaint = Paint()..color = const Color(0xFF475569);
    final tableBorder = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final tableRect = Rect.fromLTWH(tableX, tableY, 88, 14);
    canvas.drawRect(tableRect, tablePaint);
    canvas.drawRect(tableRect, tableBorder);

    // 3 Judges Taking Notes
    for (int j = 0; j < 3; j++) {
      final jx = tableX + 8 + (j * 26);
      final judgeBody = Paint()..color = const Color(0xFF1E293B);
      final judgeHead = Paint()..color = const Color(0xFFF2B880);

      // Head
      canvas.drawRect(Rect.fromLTWH(jx, tableY - 14, 10, 10), judgeHead);
      // Body
      canvas.drawRect(Rect.fromLTWH(jx, tableY - 4, 10, 6), judgeBody);
      // Official Scorecard
      final paper = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(jx + 2, tableY + 2, 7, 6), paper);
    }
  }

  void _renderReferee(Canvas canvas, double rx, double ry) {
    // Official black/white striped referee
    final refShirt = Paint()..color = const Color(0xFFF4ECE1);
    final refPants = Paint()..color = const Color(0xFF1A1C2C);
    final skin = Paint()..color = const Color(0xFFF2B880);

    // Pants
    canvas.drawRect(Rect.fromLTWH(rx, ry + 12, 11, 14), refPants);
    // Torso with black vertical referee stripes
    canvas.drawRect(Rect.fromLTWH(rx - 1, ry + 4, 13, 10), refShirt);
    final stripe = Paint()..color = const Color(0xFF1A1C2C);
    canvas.drawRect(Rect.fromLTWH(rx + 2, ry + 4, 2, 10), stripe);
    canvas.drawRect(Rect.fromLTWH(rx + 6, ry + 4, 2, 10), stripe);

    // Head
    canvas.drawRect(Rect.fromLTWH(rx + 1, ry - 4, 9, 8), skin);
    final hair = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(rx + 1, ry - 4, 9, 3), hair);
  }

  void _renderRetroBanner(Canvas canvas, String title, double cx, double cy, Color tagColor) {
    final bannerPaint = Paint()..color = tagColor;
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final bannerRect = Rect.fromCenter(center: Offset(cx, cy), width: 300, height: 24);
    canvas.drawRect(bannerRect, bannerPaint);
    canvas.drawRect(bannerRect, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
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
