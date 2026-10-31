// lib/ui/components/live_bakuran_camp.dart
// Multi-Floor Cutaway Camp View (Kairosoft-style side view building with street & yard).

import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/equipment.dart';
import '../../domain/models/student.dart';
import '../../game/asset_registry.dart';
import '../../providers/game_state_provider.dart';
import '../overlays/estudyante_modal.dart';
import '../overlays/itayo_modal.dart';
import '../retro_ui.dart';
import '../theme.dart';

class LiveBakuranCampView extends StatefulWidget {
  final GameStateProvider gameState;
  final void Function(int slotIndex)? onSlotTapped;

  const LiveBakuranCampView({
    super.key,
    required this.gameState,
    this.onSlotTapped,
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
        // Striking Dummy
        _bayaniX = 0.22;
        _bayaniBubble = 'Hataw!';
        _floatingStat = '+3 LAKAS';
        _floatingStatY = 0.0;
      } else if (_bayaniActionState == 2) {
        // Studying
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

  void _openItayoModal(int floor) {
    showDialog(
      context: context,
      builder: (ctx) => ItayoModal(
        gameState: widget.gameState,
        initialFloor: floor,
      ),
    );
  }

  void _openEstudyanteModal([Student? student]) {
    showDialog(
      context: context,
      builder: (ctx) => EstudyanteModal(
        gameState: widget.gameState,
        initialSelectedStudent: student,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final floors = state.unlockedFloors;

    // Dynamic height: 75px per floor + 40px roof/sky + 50px yard & street
    final totalHeight = 40.0 + (floors * 70.0) + 70.0;

    return RetroBox(
      title: '${state.fighter.gymName.toUpperCase()} (BAKURAN TRAINING CAMP)',
      titleTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ESTUDYANTE BUTTON
          InkWell(
            onTap: () => _openEstudyanteModal(),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                border: Border.all(color: const Color(0xFF1A1C2C)),
              ),
              child: Text(
                'ESTUDYANTE (${state.students.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontFamily: 'Silkscreen',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ITAYO (BUILD) BUTTON
          InkWell(
            onTap: () => _openItayoModal(1),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                border: Border.all(color: const Color(0xFF1A1C2C)),
              ),
              child: const Text(
                'ITAYO (BUILD)',
                style: TextStyle(
                  color: Color(0xFF1A1C2C),
                  fontSize: 7.5,
                  fontFamily: 'Silkscreen',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // EXPAND FLOOR BUTTON
          if (floors < 5) ...[
            InkWell(
              onTap: state.canExpandFloor ? () => state.expandFloor() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: state.canExpandFloor ? const Color(0xFF16A34A) : const Color(0xFF334155),
                  border: Border.all(color: RetroColors.gold),
                ),
                child: Text(
                  'EXPAND ${floors + 1}F (P${state.nextFloorCost})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
                    fontFamily: 'Silkscreen',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        child: SizedBox(
          height: min(totalHeight, 340.0),
          child: SingleChildScrollView(
            reverse: true, // Scroll from ground up
            child: SizedBox(
              height: totalHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  // 1. CUTAWAY MULTI-FLOOR CANVAS
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MultiFloorCutawayCampPainter(
                        unlockedFloors: floors,
                        placements: state.placements,
                        camp: state.camp,
                        students: state.students,
                        bayaniX: _bayaniX,
                        bayaniAction: _bayaniActionState,
                        coachX: _coachX,
                        tricycleX: _tricycleX,
                        pedestrianX: _pedestrianX,
                        animTick: _animController.value,
                      ),
                    ),
                  ),

                  // 2. INTERACTIVE TAP REGIONS PER FLOOR
                  for (int f = 1; f <= floors; f++) ...[
                    Positioned(
                      left: 10,
                      top: 40.0 + ((floors - f) * 70.0),
                      width: 220,
                      height: 64,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _openItayoModal(f),
                      ),
                    ),
                  ],

                  // 3. BAYANI SPEECH & FLOATING STAT OVERLAY (GROUND FLOOR)
                  Positioned(
                    left: 20 + (_bayaniX * 220),
                    bottom: 74 + _floatingStatY,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_floatingStat.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            color: const Color(0xFFFDE047),
                            child: Text(
                              _floatingStat,
                              style: const TextStyle(
                                color: Color(0xFF1A1C2C),
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Silkscreen',
                              ),
                            ),
                          ),
                        _buildSpeechBubble(_bayaniBubble, const Color(0xFFDC2626)),
                      ],
                    ),
                  ),

                  // 4. COACH SPEECH OVERLAY
                  Positioned(
                    left: 20 + (_coachX * 220),
                    bottom: 74,
                    child: _buildSpeechBubble(_coachBubble, const Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(String text, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Silkscreen',
        ),
      ),
    );
  }
}

/// CustomPainter rendering multi-floor stacked building with street & yard
class _MultiFloorCutawayCampPainter extends CustomPainter {
  final int unlockedFloors;
  final List<PlacedEquipment> placements;
  final dynamic camp;
  final List<Student> students;
  final double bayaniX;
  final int bayaniAction;
  final double coachX;
  final double tricycleX;
  final double pedestrianX;
  final double animTick;

  _MultiFloorCutawayCampPainter({
    required this.unlockedFloors,
    required this.placements,
    required this.camp,
    required this.students,
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

    // 1. SKY & DISTANT MOUNTAIN (TOP)
    final skyPaint = Paint()..color = const Color(0xFF60A5FA);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 40), skyPaint);

    final sunPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawRect(Rect.fromLTWH(w * 0.84, 8, 16, 16), sunPaint);

    // 2. CORRUGATED TIN ROOF & SIGNBOARD
    final roofY = 32.0;
    final roofPaint = Paint()..color = const Color(0xFF64748B);
    final roofTrim = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(6, roofY, w - 12, 8), roofPaint);
    canvas.drawRect(Rect.fromLTWH(4, roofY + 6, w - 8, 3), roofTrim);

    // 3. STACKED MULTI-FLOORS (from top floor down to 1F)
    final floorHeight = 70.0;
    final startY = roofY + 8.0;

    for (int f = unlockedFloors; f >= 1; f--) {
      final floorIndexFromTop = unlockedFloors - f;
      final fy = startY + (floorIndexFromTop * floorHeight);

      _drawFloorRoom(canvas, w, fy, floorHeight, floorNum: f);
    }

    // 4. OUTDOOR YARD (BAKURAN LANE)
    final yardY = startY + (unlockedFloors * floorHeight);
    final yardHeight = 32.0;
    final yardPaint = Paint()..color = const Color(0xFF8C532B);
    canvas.drawRect(Rect.fromLTWH(6, yardY, w - 12, yardHeight), yardPaint);

    // Palm Tree in Yard
    _drawPalmTree(canvas, 18, yardY + yardHeight);
    _drawPalmTree(canvas, w - 24, yardY + yardHeight);

    // 5. BOTTOM STREET VIEW: SIDEWALK & ROAD
    final streetY = yardY + yardHeight;
    final sidewalkH = 8.0;
    final sidewalkPaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawRect(Rect.fromLTWH(0, streetY, w, sidewalkH), sidewalkPaint);

    final roadY = streetY + sidewalkH;
    final roadH = h - roadY;
    final roadPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, roadY, w, roadH), roadPaint);

    // Dashed road lines
    final dashPaint = Paint()
      ..color = const Color(0xFFF4ECE1)
      ..strokeWidth = 2.0;
    for (double dx = 10; dx < w; dx += 28) {
      canvas.drawLine(Offset(dx, roadY + 14), Offset(dx + 14, roadY + 14), dashPaint);
    }

    // 6. ANIMATED STREET LIFE
    _drawMovingTricycle(canvas, w, roadY + 2);
    _drawWalkingPedestrian(canvas, w, streetY - 6);

    // 7. AUTONOMOUS CHARACTERS & STUDENTS
    final groundFloorBottom = startY + (unlockedFloors * floorHeight);
    _drawStudents(canvas, w, groundFloorBottom);
    _drawChibiCoach(canvas, w, groundFloorBottom);
  }

  void _drawFloorRoom(Canvas canvas, double w, double topY, double height, {required int floorNum}) {
    final roomRect = Rect.fromLTWH(8, topY, w - 16, height);

    // Bamboo Wall fill
    final wallPaint = Paint()..color = floorNum == 1 ? const Color(0xFFD49B6A) : const Color(0xFFC28854);
    canvas.drawRect(roomRect, wallPaint);

    // Wall slats
    final slatPaint = Paint()
      ..color = const Color(0xFFB57D42).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    for (double sy = topY + 12; sy < topY + height; sy += 12) {
      canvas.drawLine(Offset(10, sy), Offset(w - 10, sy), slatPaint);
    }

    // Wooden Support Pillars
    final postPaint = Paint()
      ..color = const Color(0xFF8C532B)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(10, topY), Offset(10, topY + height), postPaint);
    canvas.drawLine(Offset(w - 10, topY), Offset(w - 10, topY + height), postPaint);

    // Floor Base Strip
    final floorStrip = Paint()..color = const Color(0xFF564064);
    canvas.drawRect(Rect.fromLTWH(8, topY + height - 4, w - 16, 4), floorStrip);

    // Floor Level Label
    final labelBg = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(12, topY + 4, 38, 12), labelBg);
    final tp = TextPainter(
      text: TextSpan(
        text: '$floorNum' 'F ROOM',
        style: const TextStyle(
          color: RetroColors.gold,
          fontSize: 6.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'Silkscreen',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(14, topY + 5));

    // Staircase on right side connecting to lower/upper floor
    _drawStairs(canvas, w - 32, topY, height);

    // 14-Tile Lane Equipment Rendering
    _drawFloorEquipment(canvas, w, topY, height, floorNum);
  }

  void _drawFloorEquipment(Canvas canvas, double w, double topY, double height, int floorNum) {
    final floorItems = placements.where((p) => p.floor == floorNum).toList();
    final laneLeft = 14.0;
    final laneWidth = w - 46.0; // Leaving room for stairs
    final tileWidth = laneWidth / 14.0;

    for (final p in floorItems) {
      final meta = camp.getEquipmentMeta(p.equipmentId);
      final itemWidthTiles = meta?.width ?? 2;
      final x = laneLeft + (p.tileX * tileWidth);
      final itemW = max(16.0, itemWidthTiles * tileWidth - 2.0);
      final itemH = 26.0;
      final y = topY + height - itemH - 4;

      final label = meta?.name != null
          ? (meta!.name.length > 5 ? meta.name.substring(0, 5).toUpperCase() : meta.name.toUpperCase())
          : p.equipmentId.substring(0, min(5, p.equipmentId.length)).toUpperCase();

      Color itemColor = const Color(0xFFF4B41B);
      if (p.equipmentId.contains('yantok') || p.equipmentId.contains('baston')) {
        itemColor = const Color(0xFF8C532B);
      } else if (p.equipmentId.contains('sako') || p.equipmentId.contains('tire') || p.equipmentId.contains('gulong')) {
        itemColor = const Color(0xFFDC2626);
      } else if (p.equipmentId.contains('banig') || p.equipmentId.contains('ring')) {
        itemColor = const Color(0xFF2563EB);
      } else if (p.equipmentId.contains('sari') || p.equipmentId.contains('mesa')) {
        itemColor = const Color(0xFF16A34A);
      }

      AssetRegistry.drawPlaceholder(
        canvas,
        Rect.fromLTWH(x, y, itemW, itemH),
        label: label,
        color: itemColor,
        fontSize: 5.5,
      );
    }
  }

  void _drawStairs(Canvas canvas, double x, double topY, double height) {
    final stairPaint = Paint()
      ..color = const Color(0xFF8C532B)
      ..strokeWidth = 2.0;

    for (double sy = topY + 8; sy < topY + height - 6; sy += 8) {
      canvas.drawLine(Offset(x, sy), Offset(x + 18, sy + 6), stairPaint);
    }
  }

  void _drawPalmTree(Canvas canvas, double x, double baseGroundY) {
    final trunk = Paint()
      ..color = const Color(0xFF8C532B)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(x, baseGroundY), Offset(x + 2, baseGroundY - 26), trunk);

    final frondPaint = Paint()..color = const Color(0xFF16A34A);
    canvas.drawRect(Rect.fromLTWH(x - 10, baseGroundY - 32, 12, 5), frondPaint);
    canvas.drawRect(Rect.fromLTWH(x + 2, baseGroundY - 32, 12, 5), frondPaint);
  }

  void _drawStudents(Canvas canvas, double w, double groundFloorY) {
    final list = students.isNotEmpty ? students : [Student(id: 's1', name: 'BAYANI')];
    final floorHeight = 70.0;

    for (int i = 0; i < list.length; i++) {
      final s = list[i];
      // Distribute students across unlocked floors (0 = 1F, 1 = 2F, etc.)
      final floorIndex = (i % unlockedFloors);
      final floorGroundY = groundFloorY - (floorIndex * floorHeight);

      double sx;
      if (s.id == 'std_01' || i == 0) {
        sx = (bayaniX * w).clamp(24.0, w - 40.0);
      } else {
        final wanderOffset = 0.22 + ((i * 0.28) % 0.55) + (sin(animTick * 6.28 + i) * 0.04);
        sx = (wanderOffset * w).clamp(24.0, w - 40.0);
      }
      final sy = floorGroundY - 26;

      final color = s.status == StudentStatus.injured
          ? const Color(0xFFEF4444)
          : (s.style == ArnisStyle.dobleBaston
              ? const Color(0xFFF59E0B)
              : (s.style == ArnisStyle.espadaYDaga
                  ? const Color(0xFF10B981)
                  : const Color(0xFF38BDF8)));

      AssetRegistry.drawPlaceholder(
        canvas,
        Rect.fromLTWH(sx, sy, 18, 24),
        label: s.nickname.isNotEmpty ? s.nickname.toUpperCase() : s.name.toUpperCase(),
        color: color,
        fontSize: 4.5,
      );

      // Draw bubble above student
      _drawStudentBubble(canvas, sx + 9, sy - 6, s);
    }
  }

  void _drawStudentBubble(Canvas canvas, double cx, double cy, Student s) {
    String bubbleIcon = '';
    Color bubbleBg = const Color(0xFFFDE047);

    if (s.status == StudentStatus.injured) {
      bubbleIcon = '+';
      bubbleBg = const Color(0xFFEF4444);
    } else if (s.fatigue > 70) {
      bubbleIcon = '~';
      bubbleBg = const Color(0xFF38BDF8);
    } else if (s.currentActivity == ActivityType.aral) {
      bubbleIcon = 'A';
      bubbleBg = const Color(0xFFA855F7);
    } else if (s.morale > 80) {
      bubbleIcon = '*';
      bubbleBg = const Color(0xFF22C55E);
    } else if (s.currentActivity == ActivityType.hinga) {
      bubbleIcon = 'Z';
      bubbleBg = const Color(0xFF06B6D4);
    } else {
      bubbleIcon = '!';
      bubbleBg = const Color(0xFFF59E0B);
    }

    final bgPaint = Paint()..color = bubbleBg;
    canvas.drawCircle(Offset(cx, cy), 4.5, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(cx, cy), 4.5, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: bubbleIcon,
        style: const TextStyle(
          color: Color(0xFF1A1C2C),
          fontSize: 6,
          fontWeight: FontWeight.bold,
          fontFamily: 'Silkscreen',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _drawChibiCoach(Canvas canvas, double w, double groundY) {
    final cx = (coachX * w).clamp(24.0, w - 40.0);
    final cy = groundY - 28;

    AssetRegistry.drawPlaceholder(
      canvas,
      Rect.fromLTWH(cx, cy, 20, 26),
      label: 'GURO',
      color: const Color(0xFFF4B41B),
      fontSize: 5.0,
    );
  }

  void _drawMovingTricycle(Canvas canvas, double w, double roadY) {
    final tx = tricycleX * w;
    AssetRegistry.drawPlaceholder(
      canvas,
      Rect.fromLTWH(tx, roadY, 28, 16),
      label: 'TRIKE',
      color: const Color(0xFFDC2626),
      fontSize: 5.0,
    );
  }

  void _drawWalkingPedestrian(Canvas canvas, double w, double sidewalkY) {
    final px = pedestrianX * w;
    AssetRegistry.drawPlaceholder(
      canvas,
      Rect.fromLTWH(px, sidewalkY - 4, 12, 16),
      label: 'TAO',
      color: const Color(0xFF0284C7),
      fontSize: 4.5,
    );
  }

  @override
  bool shouldRepaint(covariant _MultiFloorCutawayCampPainter oldDelegate) {
    return true;
  }
}
