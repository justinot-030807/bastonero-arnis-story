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
  double _bayaniX = 0.35; // 0.0 to 1.0 of gym width
  double _bayaniFloor = 0.0; // 0 = ground floor, 1 = upper floor
  int _bayaniActionState = 0; // 0: walking, 1: striking, 2: studying, 3: drinking buko
  double _actionTimer = 0.0;
  String _bayaniBubble = 'Sanay tayo!';
  String _floatingStat = '';
  double _floatingStatY = 0.0;

  double _coachX = 0.65;
  String _coachBubble = 'Hataw!';

  double _tricycleX = -0.3; // -0.3 to 1.3 across the road
  double _pedestrianX = 1.1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(_updateAutonomousCharacters)..repeat();
  }

  void _updateAutonomousCharacters() {
    final t = _animController.value;

    // Tricycle drives along bottom road
    _tricycleX = -0.2 + (t * 1.5) % 1.5;

    // Pedestrian walks along sidewalk
    _pedestrianX = 1.1 - (t * 1.2) % 1.4;

    _actionTimer += 0.016;

    // Autonomous AI Cycle for Bayani
    if (_actionTimer > 4.5) {
      _actionTimer = 0.0;
      final rnd = Random();
      _bayaniActionState = rnd.nextInt(4);

      if (_bayaniActionState == 1) {
        // Striking Gulong Dummy
        _bayaniX = 0.22;
        _bayaniFloor = 0.0;
        _bayaniBubble = 'Hataw!';
        _floatingStat = '+3 LAKAS';
        _floatingStatY = 0.0;
      } else if (_bayaniActionState == 2) {
        // Studying under Mango Tree
        _bayaniX = 0.72;
        _bayaniFloor = widget.gameState.maxSlots > 2 ? 1.0 : 0.0;
        _bayaniBubble = 'Aral muna!';
        _floatingStat = '+2 GRADO';
        _floatingStatY = 0.0;
      } else if (_bayaniActionState == 3) {
        // Drinking Buko
        _bayaniX = 0.48;
        _bayaniFloor = 0.0;
        _bayaniBubble = 'Sariwang Buko!';
        _floatingStat = '+10 HANGIN';
        _floatingStatY = 0.0;
      } else {
        // Walking / Stance
        _bayaniX = 0.30 + (rnd.nextDouble() * 0.35);
        _bayaniBubble = 'Bastonero!';
        _floatingStat = '';
      }

      // Coach reaction
      final coachPhrases = ['Galingan mo!', 'Bantayan ang salag!', 'Asintado!', 'Diskarte ang kailangan!'];
      _coachBubble = coachPhrases[rnd.nextInt(coachPhrases.length)];
      _coachX = 0.50 + (rnd.nextDouble() * 0.25);
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
      title: 'BAKURAN TRAINING CAMP (SIDE-VIEW CUTAWAY)',
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
          // 1. SIDE-VIEW CUTAWAY CANVAS
          SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(
              painter: _CutawayCampPainter(
                maxSlots: state.maxSlots,
                slots: state.slots,
                bayaniX: _bayaniX,
                bayaniFloor: _bayaniFloor,
                bayaniAction: _bayaniActionState,
                coachX: _coachX,
                tricycleX: _tricycleX,
                pedestrianX: _pedestrianX,
                animTick: _animController.value,
              ),
            ),
          ),

          // 2. SPEECH BUBBLES & FLOATING STATS OVERLAY
          Positioned(
            left: 20 + (_bayaniX * 260),
            top: (_bayaniFloor > 0 ? 35 : 125) - _floatingStatY,
            child: Column(
              children: [
                if (_floatingStat.isNotEmpty)
                  Text(
                    _floatingStat,
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                _buildSpeechBubble(_bayaniBubble, const Color(0xFFDC2626)),
              ],
            ),
          ),

          Positioned(
            left: 20 + (_coachX * 260),
            top: 135,
            child: _buildSpeechBubble(_coachBubble, const Color(0xFF0284C7)),
          ),

          // 3. INTERACTIVE TAP REGIONS FOR PHYSICAL SLOTS
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    // Ground Floor Slots (Slots 0 and 1, plus 2 and 3 if expanded)
                    for (int i = 0; i < state.maxSlots; i++) ...[
                      _buildSlotTapZone(
                        slotIndex: i,
                        rect: _getSlotRect(i, state.maxSlots, w, h),
                        facility: state.slots[i],
                      ),
                    ],
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
    if (maxSlots <= 2) {
      // 2 slots on ground floor
      final slotW = (w - 30) / 2;
      return Rect.fromLTWH(15 + (slot * slotW), h * 0.45, slotW - 8, h * 0.35);
    } else if (maxSlots <= 4) {
      // 2 ground, 2 upper
      final row = slot ~/ 2;
      final col = slot % 2;
      final slotW = (w - 30) / 2;
      final y = row == 0 ? h * 0.45 : h * 0.08;
      return Rect.fromLTWH(15 + (col * slotW), y, slotW - 8, h * 0.35);
    } else {
      // 3 ground, 3 upper
      final row = slot ~/ 3;
      final col = slot % 3;
      final slotW = (w - 36) / 3;
      final y = row == 0 ? h * 0.45 : h * 0.08;
      return Rect.fromLTWH(12 + (col * slotW), y, slotW - 6, h * 0.35);
    }
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
              color: facility != null ? const Color(0xFFF4B41B).withValues(alpha: 0.4) : const Color(0xFF64748B).withValues(alpha: 0.3),
              width: 1.5,
            ),
            color: Colors.transparent,
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: const Color(0xFF1A1C2C),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// CustomPainter that renders the Side-View Cutaway Gym and Street View
class _CutawayCampPainter extends CustomPainter {
  final int maxSlots;
  final List<FacilityModel?> slots;
  final double bayaniX;
  final double bayaniFloor;
  final int bayaniAction;
  final double coachX;
  final double tricycleX;
  final double pedestrianX;
  final double animTick;

  _CutawayCampPainter({
    required this.maxSlots,
    required this.slots,
    required this.bayaniX,
    required this.bayaniFloor,
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

    final skyH = h * 0.40;
    final streetY = h * 0.82;
    final groundFloorY = h * 0.44;

    // 1. SKY & DISTANT TROPICAL TREES
    final skyPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, skyH), skyPaint);

    final sunPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawRect(Rect.fromLTWH(w * 0.8, 10, 24, 24), sunPaint);

    // Distant Coconut Tree Canopies
    final foliagePaint = Paint()..color = const Color(0xFF2F5738);
    for (double x = -10; x < w + 20; x += 36) {
      canvas.drawRect(Rect.fromLTWH(x, skyH - 32, 28, 20), foliagePaint);
    }

    // 2. CUTAWAY WOODEN & BAMBOO GYM BUILDING
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Upper Floor (if expanded > 2 slots)
    if (maxSlots > 2) {
      final upperRect = Rect.fromLTWH(8, 18, w - 16, groundFloorY - 18);
      final roomPaint = Paint()..color = const Color(0xFF564064);
      canvas.drawRect(upperRect, roomPaint);
      canvas.drawRect(upperRect, borderPaint);

      // Veranda Wooden Railing
      final railingPaint = Paint()
        ..color = const Color(0xFF8C532B)
        ..strokeWidth = 3;
      for (double rx = 14; rx < w - 20; rx += 12) {
        canvas.drawLine(Offset(rx, groundFloorY - 14), Offset(rx, groundFloorY), railingPaint);
      }
      canvas.drawLine(Offset(10, groundFloorY - 14), Offset(w - 10, groundFloorY - 14), railingPaint);
    }

    // Ground Floor Training Room
    final groundRect = Rect.fromLTWH(8, groundFloorY, w - 16, streetY - groundFloorY);
    final dirtFloorPaint = Paint()..color = const Color(0xFFD49B6A);
    canvas.drawRect(groundRect, dirtFloorPaint);
    canvas.drawRect(groundRect, borderPaint);

    // Bamboo Wall Slat Textures
    final slatPaint = Paint()
      ..color = const Color(0xFFB57D42)
      ..strokeWidth = 1.5;
    for (double sy = groundFloorY + 12; sy < streetY; sy += 14) {
      canvas.drawLine(Offset(10, sy), Offset(w - 10, sy), slatPaint);
    }

    // 3. PHYSICAL PIXEL FACILITIES IN ROOMS
    _drawPhysicalFacilities(canvas, w, groundFloorY, streetY);

    // 4. AUTONOMOUS CHARACTER PIXEL SPRITES
    _drawAutonomousFighter(canvas, w, groundFloorY, streetY);
    _drawAutonomousCoach(canvas, w, groundFloorY, streetY);

    // 5. BOTTOM STREET VIEW (ASPHALT ROAD & SIDEWALK)
    final sidewalkPaint = Paint()..color = const Color(0xFF8B9BB4);
    canvas.drawRect(Rect.fromLTWH(0, streetY, w, 10), sidewalkPaint);

    final roadPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, streetY + 10, w, h - (streetY + 10)), roadPaint);

    // Road White Dashes
    final dashPaint = Paint()
      ..color = const Color(0xFFF4ECE1)
      ..strokeWidth = 2;
    for (double dx = 10; dx < w; dx += 30) {
      canvas.drawLine(Offset(dx, streetY + 24), Offset(dx + 14, streetY + 24), dashPaint);
    }

    // 6. MOVING TRICYCLE ON STREET
    _drawMovingTricycle(canvas, w, streetY + 10);

    // 7. WALKING PEDESTRIAN ON SIDEWALK
    _drawWalkingPedestrian(canvas, w, streetY - 14);
  }

  void _drawPhysicalFacilities(Canvas canvas, double w, double upperY, double groundY) {
    for (int i = 0; i < maxSlots; i++) {
      final f = slots[i];
      if (f == null) continue;

      final isUpper = i >= 3;
      final col = isUpper ? (i - 3) : i;
      final slotSpan = w / (isUpper ? 3 : (maxSlots > 2 ? 3 : 2));
      final cx = (col * slotSpan) + (slotSpan * 0.5);
      final cy = isUpper ? upperY - 18 : groundY - 18;

      switch (f.type) {
        case FacilityType.gulongTarget:
          // Heavy truck tires stacked on bamboo post
          final postPaint = Paint()
            ..color = const Color(0xFF564064)
            ..strokeWidth = 4;
          canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 35), postPaint);

          final tirePaint = Paint()..color = const Color(0xFF1A1C2C);
          canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 28, 20, 8), tirePaint);
          canvas.drawRect(Rect.fromLTWH(cx - 12, cy - 18, 24, 9), tirePaint);
          canvas.drawRect(Rect.fromLTWH(cx - 14, cy - 9, 28, 9), tirePaint);
          break;

        case FacilityType.studyDesk:
          // Mango tree canopy with desk
          final trunk = Paint()
            ..color = const Color(0xFF8C532B)
            ..strokeWidth = 5;
          canvas.drawLine(Offset(cx - 14, cy), Offset(cx - 14, cy - 40), trunk);

          final mangoCanopy = Paint()..color = const Color(0xFF2F5738);
          canvas.drawRect(Rect.fromLTWH(cx - 30, cy - 50, 36, 20), mangoCanopy);

          // Golden ripe mangoes hanging
          final mangoPaint = Paint()..color = const Color(0xFFF4B41B);
          canvas.drawRect(Rect.fromLTWH(cx - 24, cy - 32, 4, 6), mangoPaint);
          canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 34, 4, 6), mangoPaint);

          // Wooden Study Desk & Books
          final deskPaint = Paint()..color = const Color(0xFFB57D42);
          canvas.drawRect(Rect.fromLTWH(cx - 8, cy - 16, 24, 16), deskPaint);
          final bookPaint = Paint()..color = const Color(0xFF38BDF8);
          canvas.drawRect(Rect.fromLTWH(cx - 4, cy - 20, 10, 4), bookPaint);
          break;

        case FacilityType.bukoStand:
          // Striped umbrella and coconut rack
          final pole = Paint()
            ..color = const Color(0xFFB57D42)
            ..strokeWidth = 3;
          canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 38), pole);

          // Striped Awning (Red & Cream)
          final awningRed = Paint()..color = const Color(0xFFDC2626);
          final awningWhite = Paint()..color = const Color(0xFFF4ECE1);
          canvas.drawRect(Rect.fromLTWH(cx - 20, cy - 42, 20, 8), awningRed);
          canvas.drawRect(Rect.fromLTWH(cx, cy - 42, 20, 8), awningWhite);

          // Counter with green coconuts
          final counter = Paint()..color = const Color(0xFF8C532B);
          canvas.drawRect(Rect.fromLTWH(cx - 16, cy - 16, 32, 16), counter);
          final nutPaint = Paint()..color = const Color(0xFF4ADE80);
          canvas.drawCircle(Offset(cx - 8, cy - 18), 4, nutPaint);
          canvas.drawCircle(Offset(cx + 4, cy - 18), 4, nutPaint);
          break;

        case FacilityType.sparringRing:
        case FacilityType.footworkTires:
          // Bamboo sparring mat
          final mat = Paint()..color = const Color(0xFFE2E8F0);
          canvas.drawRect(Rect.fromLTWH(cx - 22, cy - 8, 44, 8), mat);
          final matRope = Paint()
            ..color = const Color(0xFFDC2626)
            ..strokeWidth = 2;
          canvas.drawLine(Offset(cx - 22, cy - 18), Offset(cx + 22, cy - 18), matRope);
          break;
      }
    }
  }

  void _drawAutonomousFighter(Canvas canvas, double w, double upperY, double groundY) {
    final fx = (bayaniX * w).clamp(20.0, w - 30.0);
    final fy = bayaniFloor > 0 ? (upperY - 24) : (groundY - 24);

    final bodyPaint = Paint()..color = const Color(0xFF1E293B);
    final skinPaint = Paint()..color = const Color(0xFFF2B880);
    final bandPaint = Paint()..color = const Color(0xFFDC2626);
    final stickPaint = Paint()
      ..color = const Color(0xFFF4B41B)
      ..strokeWidth = 2.5;

    // Torso & Pants
    canvas.drawRect(Rect.fromLTWH(fx, fy + 8, 10, 14), bodyPaint);
    // Head & Red Bandana
    canvas.drawRect(Rect.fromLTWH(fx + 1, fy, 8, 8), skinPaint);
    canvas.drawRect(Rect.fromLTWH(fx, fy + 2, 10, 3), bandPaint);

    if (bayaniAction == 1) {
      // Striking baston swing
      final swing = sin(animTick * 20 * pi) * 12.0;
      canvas.drawLine(Offset(fx + 8, fy + 10), Offset(fx + 18, fy + 4 + swing), stickPaint);
    } else {
      // Resting / Idle stick held upright
      canvas.drawLine(Offset(fx + 8, fy + 12), Offset(fx + 14, fy), stickPaint);
    }
  }

  void _drawAutonomousCoach(Canvas canvas, double w, double upperY, double groundY) {
    final cx = (coachX * w).clamp(20.0, w - 30.0);
    final cy = groundY - 24;

    final bodyPaint = Paint()..color = const Color(0xFF2F5738);
    final skinPaint = Paint()..color = const Color(0xFFF2B880);
    final towelPaint = Paint()..color = const Color(0xFFF4ECE1);

    canvas.drawRect(Rect.fromLTWH(cx, cy + 8, 11, 14), bodyPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 1, cy, 9, 8), skinPaint);
    // Towel draped over coach shoulder
    canvas.drawRect(Rect.fromLTWH(cx, cy + 8, 4, 10), towelPaint);
  }

  void _drawMovingTricycle(Canvas canvas, double w, double roadY) {
    final tx = tricycleX * w;
    canvas.save();
    canvas.translate(tx, roadY);
    // Draw 24x16 tricycle matrix
    for (int y = 0; y < PixelArtCatalog.tricycleSprite.length; y++) {
      final row = PixelArtCatalog.tricycleSprite[y];
      for (int x = 0; x < row.length; x++) {
        final char = row[x];
        if (char == '.') continue;
        final p = Paint()..color = RetroPalette.colorForChar(char);
        canvas.drawRect(Rect.fromLTWH(x * 1.5, y * 1.2, 1.5, 1.2), p);
      }
    }
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
  bool shouldRepaint(covariant _CutawayCampPainter oldDelegate) {
    return true;
  }
}
