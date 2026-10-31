import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/facility_model.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';

class LiveBakuranCampView extends StatefulWidget {
  final GameStateProvider gameState;
  final void Function(int slotIndex) onSlotTapped;

  const LiveBakuranCampView({
    super.key,
    required this.gameState,
    required this.onSlotTapped,
  });

  @override
  State<LiveBakuranCampView> createState() => _LiveBakuranCampViewState();
}

class _LiveBakuranCampViewState extends State<LiveBakuranCampView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Autonomous Character States
  double _bayaniX = 0.28;
  int _bayaniActionState = 0; // 0: walking, 1: striking, 2: studying, 3: resting
  double _actionTimer = 0.0;
  String _bayaniBubble = 'Sanay tayo!';
  String _floatingStat = '';
  double _floatingStatY = 0.0;

  double _coachX = 0.65;
  String _coachBubble = 'Hataw!';

  double _tricycleX = -0.3;
  double _pedestrianX = 1.1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateAutonomousCharacters)..repeat();
  }

  void _updateAutonomousCharacters() {
    final t = _animController.value;

    // Tricycle drives along bottom street
    _tricycleX = -0.25 + (t * 1.5) % 1.5;

    // Pedestrian walks along sidewalk
    _pedestrianX = 1.15 - (t * 1.2) % 1.4;

    _actionTimer += 0.016;

    // Autonomous AI Cycle for Student Fighter
    if (_actionTimer > 4.0) {
      _actionTimer = 0.0;
      final rnd = Random();
      _bayaniActionState = rnd.nextInt(4);

      if (_bayaniActionState == 1) {
        // Striking Tire Dummy
        _bayaniX = 0.22;
        _bayaniBubble = 'Hataw!';
        _floatingStat = '+3 LAKAS';
        _floatingStatY = 0.0;
      } else if (_bayaniActionState == 2) {
        // Studying under Mango Tree
        _bayaniX = 0.74;
        _bayaniBubble = 'Aral muna!';
        _floatingStat = '+2 GRADO';
        _floatingStatY = 0.0;
      } else if (_bayaniActionState == 3) {
        // Drinking Buko / Resting
        _bayaniX = 0.48;
        _bayaniBubble = 'Sariwang Buko!';
        _floatingStat = '+10 HANGIN';
        _floatingStatY = 0.0;
      } else {
        // Walking around the gym
        _bayaniX = 0.30 + (rnd.nextDouble() * 0.38);
        _bayaniBubble = 'Bastonero!';
        _floatingStat = '';
      }

      // Coach reaction
      final coachPhrases = [
        'Galingan mo!',
        'Bantayan ang salag!',
        'Asintado ang palo!',
        'Diskarte at bilis!',
        'Pangalagaan ang grado!',
      ];
      _coachBubble = coachPhrases[rnd.nextInt(coachPhrases.length)];
      _coachX = 0.52 + (rnd.nextDouble() * 0.20);
    }

    if (_floatingStat.isNotEmpty) {
      _floatingStatY += 0.4;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;

    return RetroBox(
      title: '${state.fighter.gymName.toUpperCase()} (BAKURAN TRAINING CAMP)',
      titleTrailing: state.maxSlots < 6
          ? InkWell(
              onTap: state.pesos >= 1800 ? () => state.expandGymSlots() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: state.pesos >= 1800 ? const Color(0xFF16A34A) : const Color(0xFF334155),
                  border: Border.all(color: const Color(0xFFF4B41B)),
                ),
                child: const Text(
                  'EXPAND 2ND FLOOR (P1,800)',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // 1. SIDE-VIEW CUTAWAY CANVAS (PROVINCIAL BAKURAN SCENERY)
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CustomPaint(
              painter: _AuthenticBakuranCampPainter(
                maxSlots: state.maxSlots,
                slots: state.slots,
                bayaniX: _bayaniX,
                bayaniAction: _bayaniActionState,
                coachX: _coachX,
                tricycleX: _tricycleX,
                pedestrianX: _pedestrianX,
                animTick: _animController.value,
              ),
            ),
          ),

          // 2. SPEECH BUBBLE & FLOATING STAT GAINS OVERLAY
          Positioned(
            left: 20 + (_bayaniX * 240),
            top: 100 - _floatingStatY,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_floatingStat.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    color: const Color(0xFFFDE047),
                    child: Text(
                      _floatingStat,
                      style: const TextStyle(
                        color: Color(0xFF1A1C2C),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                _buildSpeechBubble(_bayaniBubble, const Color(0xFFDC2626)),
              ],
            ),
          ),

          // 3. COACH SPEECH BUBBLE OVERLAY
          Positioned(
            left: 20 + (_coachX * 240),
            top: 110,
            child: _buildSpeechBubble(_coachBubble, const Color(0xFF16A34A)),
          ),

          // 4. INTERACTIVE FACILITY TAP BOXES
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    for (int i = 0; i < state.maxSlots; i++)
                      _buildSlotTapZone(
                        slotIndex: i,
                        rect: _getSlotRect(i, state.maxSlots, w, h),
                        facility: state.slots[i],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Rect _getSlotRect(int slot, int maxSlots, double w, double h) {
    final slotW = (w - 24) / (maxSlots > 2 ? 3 : 2);
    final row = slot ~/ (maxSlots > 2 ? 3 : 2);
    final col = slot % (maxSlots > 2 ? 3 : 2);
    final y = row == 0 ? h * 0.40 : h * 0.08;
    return Rect.fromLTWH(12 + (col * slotW), y, slotW - 6, h * 0.36);
  }

  Widget _buildSlotTapZone({
    required int slotIndex,
    required Rect rect,
    required FacilityModel? facility,
  }) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        onTap: () => widget.onSlotTapped(slotIndex),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: facility != null
                  ? const Color(0xFFF4B41B).withValues(alpha: 0.35)
                  : const Color(0xFF64748B).withValues(alpha: 0.3),
              width: 1.2,
            ),
            color: Colors.transparent,
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: const Color(0xFF0F172A),
              child: Text(
                facility != null ? 'L${facility.level}' : '+SLOT ${slotIndex + 1}',
                style: const TextStyle(
                  color: Color(0xFFFDE047),
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(String text, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECE1),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1A1C2C),
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// CustomPainter that renders a rich, authentic Filipino Provincial Backyard Camp
class _AuthenticBakuranCampPainter extends CustomPainter {
  final int maxSlots;
  final List<FacilityModel?> slots;
  final double bayaniX;
  final int bayaniAction;
  final double coachX;
  final double tricycleX;
  final double pedestrianX;
  final double animTick;

  _AuthenticBakuranCampPainter({
    required this.maxSlots,
    required this.slots,
    required this.bayaniX,
    required this.bayaniAction,
    required this.coachX,
    required this.tricycleX,
    required this.pedestrianX,
    required this.animTick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final skyH = h * 0.36;
    final groundY = h * 0.40;
    final streetY = h * 0.82;

    // 1. SUNNY PROVINCE SKY & DISTANT MOUNTAINS
    final skyPaint = Paint()..color = const Color(0xFF60A5FA);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, skyH), skyPaint);

    // Warm Sun
    final sunPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawRect(Rect.fromLTWH(w * 0.82, 12, 22, 22), sunPaint);

    // Fluffy Pixel Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawRect(Rect.fromLTWH(w * 0.15, 14, 38, 10), cloudPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.20, 8, 26, 12), cloudPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.55, 18, 32, 8), cloudPaint);

    // Distant Green Mountain Silhouette (Mt. Arayat style)
    final mountainPaint = Paint()..color = const Color(0xFF15803D);
    final mountainPath = Path()
      ..moveTo(0, skyH)
      ..lineTo(w * 0.25, skyH - 24)
      ..lineTo(w * 0.45, skyH - 12)
      ..lineTo(w * 0.70, skyH - 32)
      ..lineTo(w, skyH - 8)
      ..lineTo(w, skyH)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // Coconut Palm Trees with trunks from the ground (NOT floating blocks!)
    _drawPalmTree(canvas, 18, skyH);
    _drawPalmTree(canvas, w - 24, skyH);

    // 2. WOODEN & BAMBOO TRAINING CAMP (BAKURAN PAVILION)
    final campWallPaint = Paint()..color = const Color(0xFFD49B6A); // Warm bamboo/wood
    final campRect = Rect.fromLTWH(8, groundY, w - 16, streetY - groundY);
    canvas.drawRect(campRect, campWallPaint);

    // Corrugated Tin Roof (Yero)
    final roofPaint = Paint()..color = const Color(0xFF64748B);
    final roofTrim = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(4, groundY - 8, w - 8, 8), roofPaint);
    canvas.drawRect(Rect.fromLTWH(2, groundY - 2, w - 4, 3), roofTrim);

    // Bamboo Wall Slat Textures
    final slatPaint = Paint()
      ..color = const Color(0xFFB57D42)
      ..strokeWidth = 1.2;
    for (double sy = groundY + 12; sy < streetY; sy += 12) {
      canvas.drawLine(Offset(10, sy), Offset(w - 10, sy), slatPaint);
    }

    // Heavy Wooden Support Posts
    final postPaint = Paint()
      ..color = const Color(0xFF8C532B)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(14, groundY), Offset(14, streetY), postPaint);
    canvas.drawLine(Offset(w - 14, groundY), Offset(w - 14, streetY), postPaint);
    if (w > 300) {
      canvas.drawLine(Offset(w * 0.5, groundY), Offset(w * 0.5, streetY), postPaint);
    }

    // Dirt & Grass Ground Floor
    final dirtFloorPaint = Paint()..color = const Color(0xFF8C532B);
    canvas.drawRect(Rect.fromLTWH(8, streetY - 6, w - 16, 6), dirtFloorPaint);

    // 3. PHYSICAL DETAILED PIXEL TRAINING FACILITIES
    _drawDetailedFacilities(canvas, w, groundY, streetY);

    // 4. AUTONOMOUS CHIBI CHARACTERS (BAYANI & COACH)
    _drawChibiStudent(canvas, w, streetY - 6);
    _drawChibiCoach(canvas, w, streetY - 6);

    // 5. BOTTOM STREET VIEW: ASPHALT ROAD & SIDEWALK
    final sidewalkPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawRect(Rect.fromLTWH(0, streetY, w, 10), sidewalkPaint);

    final roadPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, streetY + 10, w, h - (streetY + 10)), roadPaint);

    // White dashed road lines
    final dashPaint = Paint()
      ..color = const Color(0xFFF4ECE1)
      ..strokeWidth = 2.0;
    for (double dx = 10; dx < w; dx += 28) {
      canvas.drawLine(Offset(dx, streetY + 22), Offset(dx + 14, streetY + 22), dashPaint);
    }

    // 6. ANIMATED RETRO TRICYCLE
    _drawMovingTricycle(canvas, w, streetY + 10);

    // 7. PEDESTRIAN ON SIDEWALK
    _drawWalkingPedestrian(canvas, w, streetY - 10);
  }

  void _drawPalmTree(Canvas canvas, double x, double baseGroundY) {
    // Curved trunk from ground
    final trunk = Paint()
      ..color = const Color(0xFF8C532B)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(x, baseGroundY), Offset(x + 4, baseGroundY - 32), trunk);

    // Palm Fronds
    final frondPaint = Paint()..color = const Color(0xFF16A34A);
    canvas.drawRect(Rect.fromLTWH(x - 12, baseGroundY - 40, 16, 6), frondPaint);
    canvas.drawRect(Rect.fromLTWH(x + 2, baseGroundY - 40, 16, 6), frondPaint);
    canvas.drawRect(Rect.fromLTWH(x - 8, baseGroundY - 44, 20, 6), frondPaint);
  }

  void _drawDetailedFacilities(Canvas canvas, double w, double topY, double bottomY) {
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f == null) continue;

      final cols = maxSlots > 2 ? 3 : 2;
      final col = i % cols;
      final slotSpan = (w - 24) / cols;
      final cx = 12 + (col * slotSpan) + (slotSpan * 0.5);
      final cy = bottomY - 14;

      switch (f.type) {
        case FacilityType.gulongTarget:
          // Heavy truck tires stacked on a solid wooden post
          final post = Paint()
            ..color = const Color(0xFF564064)
            ..strokeWidth = 5;
          canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 42), post);

          // 3 Stacked Rubber Tires with rope bindings
          final tire = Paint()..color = const Color(0xFF1A1C2C);
          final rim = Paint()..color = const Color(0xFF334155);
          final rope = Paint()..color = const Color(0xFFF4B41B);

          canvas.drawRect(Rect.fromLTWH(cx - 12, cy - 36, 24, 10), tire);
          canvas.drawRect(Rect.fromLTWH(cx - 8, cy - 34, 16, 6), rim);

          canvas.drawRect(Rect.fromLTWH(cx - 14, cy - 24, 28, 11), tire);
          canvas.drawRect(Rect.fromLTWH(cx - 9, cy - 22, 18, 7), rim);

          canvas.drawRect(Rect.fromLTWH(cx - 16, cy - 12, 32, 12), tire);
          canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 10, 20, 8), rim);

          // Wrapped protective rope
          canvas.drawRect(Rect.fromLTWH(cx - 3, cy - 35, 6, 34), rope);
          break;

        case FacilityType.studyDesk:
          // Mango Tree Shade + Study Table & Books
          final trunk = Paint()
            ..color = const Color(0xFF8C532B)
            ..strokeWidth = 6;
          canvas.drawLine(Offset(cx - 16, cy), Offset(cx - 16, cy - 46), trunk);

          // Lush Mango Canopy
          final foliage = Paint()..color = const Color(0xFF15803D);
          canvas.drawRect(Rect.fromLTWH(cx - 36, cy - 56, 44, 24), foliage);

          // Golden Yellow Mangoes
          final mango = Paint()..color = const Color(0xFFFDE047);
          canvas.drawRect(Rect.fromLTWH(cx - 28, cy - 36, 4, 6), mango);
          canvas.drawRect(Rect.fromLTWH(cx - 12, cy - 38, 4, 6), mango);
          canvas.drawRect(Rect.fromLTWH(cx - 2, cy - 40, 4, 6), mango);

          // Wooden Study Desk
          final desk = Paint()..color = const Color(0xFFB57D42);
          canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 18, 28, 18), desk);

          // Textbooks & Notepad
          final book = Paint()..color = const Color(0xFF38BDF8);
          final notebook = Paint()..color = Colors.white;
          canvas.drawRect(Rect.fromLTWH(cx - 6, cy - 23, 12, 5), book);
          canvas.drawRect(Rect.fromLTWH(cx + 8, cy - 21, 8, 3), notebook);
          break;

        case FacilityType.bukoStand:
          // Pinoy Sari-Sari / Buko Juice Stand
          final counter = Paint()..color = const Color(0xFF8C532B);
          canvas.drawRect(Rect.fromLTWH(cx - 18, cy - 20, 36, 20), counter);

          // Striped Red & White Awning Canopy
          final awningRed = Paint()..color = const Color(0xFFDC2626);
          final awningWhite = Paint()..color = const Color(0xFFF4ECE1);
          canvas.drawRect(Rect.fromLTWH(cx - 22, cy - 46, 22, 10), awningRed);
          canvas.drawRect(Rect.fromLTWH(cx, cy - 46, 22, 10), awningWhite);

          // Canopy Poles
          final pole = Paint()
            ..color = const Color(0xFF1A1C2C)
            ..strokeWidth = 2;
          canvas.drawLine(Offset(cx - 20, cy - 20), Offset(cx - 20, cy - 36), pole);
          canvas.drawLine(Offset(cx + 20, cy - 20), Offset(cx + 20, cy - 36), pole);

          // Fresh Coconuts on Counter
          final nut = Paint()..color = const Color(0xFF4ADE80);
          canvas.drawRect(Rect.fromLTWH(cx - 12, cy - 24, 6, 6), nut);
          canvas.drawRect(Rect.fromLTWH(cx - 4, cy - 24, 6, 6), nut);
          canvas.drawRect(Rect.fromLTWH(cx + 4, cy - 24, 6, 6), nut);
          break;

        case FacilityType.sparringRing:
        case FacilityType.footworkTires:
          // Agility Footwork Tires laid out on ground
          final tire = Paint()..color = const Color(0xFF1A1C2C);
          final dirt = Paint()..color = const Color(0xFF8C532B);
          canvas.drawRect(Rect.fromLTWH(cx - 20, cy - 10, 12, 8), tire);
          canvas.drawRect(Rect.fromLTWH(cx - 17, cy - 8, 6, 4), dirt);

          canvas.drawRect(Rect.fromLTWH(cx - 4, cy - 14, 12, 8), tire);
          canvas.drawRect(Rect.fromLTWH(cx - 1, cy - 12, 6, 4), dirt);

          canvas.drawRect(Rect.fromLTWH(cx + 10, cy - 10, 12, 8), tire);
          canvas.drawRect(Rect.fromLTWH(cx + 13, cy - 8, 6, 4), dirt);
          break;
      }
    }
  }

  void _drawChibiStudent(Canvas canvas, double w, double groundY) {
    final fx = (bayaniX * w).clamp(24.0, w - 34.0);
    final fy = groundY - 32;

    canvas.save();
    canvas.translate(fx, fy);

    // Pick sprite based on action
    List<String> matrix = PixelArtCatalog.chibiBayaniIdle;
    if (bayaniAction == 1) {
      matrix = PixelArtCatalog.chibiBayaniPunch;
    } else if (bayaniAction == 2) {
      matrix = PixelArtCatalog.chibiBayaniSit;
    } else {
      final isStep = (animTick * 8).toInt() % 2 == 1;
      matrix = isStep ? PixelArtCatalog.chibiBayaniStep : PixelArtCatalog.chibiBayaniIdle;
    }

    _drawMatrix(canvas, matrix, 1.8);
    canvas.restore();
  }

  void _drawChibiCoach(Canvas canvas, double w, double groundY) {
    final cx = (coachX * w).clamp(24.0, w - 34.0);
    final cy = groundY - 32;

    canvas.save();
    canvas.translate(cx, cy);
    _drawMatrix(canvas, PixelArtCatalog.coachKanorPortrait, 1.8);
    canvas.restore();
  }

  void _drawMatrix(Canvas canvas, List<String> matrix, double pixelSize) {
    final paint = Paint()..isAntiAlias = false;
    for (int y = 0; y < matrix.length; y++) {
      final row = matrix[y];
      for (int x = 0; x < row.length; x++) {
        final char = row[x];
        if (char == '.') continue;
        paint.color = RetroPalette.colorForChar(char);
        canvas.drawRect(Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize), paint);
      }
    }
  }

  void _drawMovingTricycle(Canvas canvas, double w, double roadY) {
    final tx = tricycleX * w;
    canvas.save();
    canvas.translate(tx, roadY);
    _drawMatrix(canvas, PixelArtCatalog.tricycleSprite, 1.4);
    canvas.restore();
  }

  void _drawWalkingPedestrian(Canvas canvas, double w, double sidewalkY) {
    final px = pedestrianX * w;
    final pPaint = Paint()..color = const Color(0xFF0284C7);
    final skin = Paint()..color = const Color(0xFFF2B880);

    canvas.drawRect(Rect.fromLTWH(px, sidewalkY + 6, 8, 12), pPaint);
    canvas.drawRect(Rect.fromLTWH(px + 1, sidewalkY, 6, 6), skin);
  }

  @override
  bool shouldRepaint(covariant _AuthenticBakuranCampPainter oldDelegate) {
    return true;
  }
}
