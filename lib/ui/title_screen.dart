import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../utils/storage_service.dart';
import 'retro_ui.dart';
import 'overlays/character_creator_modal.dart';
import 'overlays/settings_modal.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  List<SaveSlotInfo> _slotsInfo = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _loadSlotsData();
  }

  Future<void> _loadSlotsData() async {
    final list = await StorageService.getAllSlotsInfo();
    if (mounted) {
      setState(() {
        _slotsInfo = list;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openCharacterCreator(BuildContext context, GameStateProvider gameState, int slotIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CharacterCreatorModal(
        gameState: gameState,
        slotIndex: slotIndex,
        onGameStarted: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _openSaveSlotsDialog(BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (ctx) => _SaveSlotsModal(
        slotsInfo: _slotsInfo,
        onSelectSlot: (slotIndex, isLoad) async {
          Navigator.of(ctx).pop();
          if (isLoad) {
            await gameState.loadSavedGame(slot: slotIndex);
            gameState.enterGame();
          } else {
            _openCharacterCreator(context, gameState, slotIndex);
          }
        },
        onDeleteSlot: (slotIndex) async {
          Navigator.of(ctx).pop();
          await StorageService.clearSlot(slotIndex);
          await _loadSlotsData();
        },
      ),
    );
  }

  void _openSettingsDialog(BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (ctx) => SettingsModal(gameState: gameState, isInGame: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final hasExistingSave = _slotsInfo.any((s) => s.hasData);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. ANIMATED 2.5D RETRO ARENA BACKGROUND
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TitleArenaBackgroundPainter(
                    animValue: _animController.value,
                  ),
                );
              },
            ),
          ),

          // 2. MAIN TITLE & MENU PANEL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // KAIROSOFT EMBOSSED TITLE GRAPHIC
                    _buildEmbossedTitle(),
                    const SizedBox(height: 8),

                    // SUBTITLE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C2C),
                        border: Border.all(color: const Color(0xFFF4B41B), width: 2),
                      ),
                      child: const Text(
                        'KAIROSOFT-STYLE ARNIS GYM SIMULATOR',
                        style: TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // RETRO ACTION BUTTONS WINDOW
                    RetroBox(
                      width: 320,
                      title: 'PANGUNAHING MENYU',
                      backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
                      borderColor: const Color(0xFF1A1C2C),
                      bevelColor: const Color(0xFFF4B41B),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // BAGONG LARO
                          RetroButton(
                            color: const Color(0xFFE6482E),
                            onTap: () {
                              _openSaveSlotsDialog(context, gameState);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PixelSpriteWidget(
                                  matrix: PixelArtCatalog.iconSanay,
                                  pixelSize: 1.2,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'BAGONG LARO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // MAGPATULOY (CONTINUE)
                          RetroButton(
                            color: hasExistingSave ? const Color(0xFF16A34A) : const Color(0xFF3F3F74),
                            onTap: hasExistingSave
                                ? () async {
                                    final lastActive = await StorageService.getActiveSlotIndex();
                                    await gameState.loadSavedGame(slot: lastActive);
                                    gameState.enterGame();
                                  }
                                : null,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PixelSpriteWidget(
                                  matrix: PixelArtCatalog.iconSpar,
                                  pixelSize: 1.2,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'MAGPATULOY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // SAVE SLOTS
                          RetroButton(
                            color: const Color(0xFF0284C7),
                            onTap: () {
                              _openSaveSlotsDialog(context, gameState);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PixelSpriteWidget(
                                  matrix: PixelArtCatalog.iconAral,
                                  pixelSize: 1.2,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'SAVE SLOTS (1-3)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // SETTINGS & JSON BACKUP
                          RetroButton(
                            color: const Color(0xFF475569),
                            onTap: () {
                              _openSettingsDialog(context, gameState);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PixelSpriteWidget(
                                  matrix: PixelArtCatalog.iconSettings,
                                  pixelSize: 1.2,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'SETTINGS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // FOOTER CREDITS
                    const Text(
                      'BASTONERO: ARNIS STORY v2.0 (FLAME & FLUTTER)\nPURE PROCEDURAL PIXEL-ART - NO EMOJIS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9,
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbossedTitle() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Deep 3D Shadow Outline
            Text(
              'BASTONERO',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 4.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 7
                  ..color = const Color(0xFF1A1C2C),
              ),
            ),
            // Bright Gold Inner Bevel
            Text(
              'BASTONERO',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 4.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = const Color(0xFFE6482E),
              ),
            ),
            // Core Gold Text Fill
            const Text(
              'BASTONERO',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 4.0,
                color: Color(0xFFF4B41B),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'ARNIS STORY',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 5.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = const Color(0xFF1A1C2C),
              ),
            ),
            const Text(
              'ARNIS STORY',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 5.0,
                color: Color(0xFFF4ECE1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// CustomPainter that renders animated 2.5D pixel arena background with cheering spectators
class _TitleArenaBackgroundPainter extends CustomPainter {
  final double animValue;

  _TitleArenaBackgroundPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Dark Stadium Atmosphere
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // 2. Spectator Bleachers with pixel cheering heads
    final bleacherPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.45), bleacherPaint);

    // Cheering crowd bounce
    final crowdColors = [
      const Color(0xFFDC2626),
      const Color(0xFF38BDF8),
      const Color(0xFFF4B41B),
      const Color(0xFF4ADE80),
      const Color(0xFFE2E8F0),
    ];

    for (int row = 0; row < 4; row++) {
      final y = 20.0 + (row * 30.0);
      for (double x = 8; x < width; x += 22) {
        final bounceOffset = sin((animValue * 2 * pi) + (x * 0.05) + row) * 3.0;
        final color = crowdColors[(x.toInt() + row) % crowdColors.length];

        final headPaint = Paint()..color = color;
        canvas.drawRect(Rect.fromLTWH(x, y + bounceOffset, 8, 8), headPaint);
        // Head outline
        final outline = Paint()
          ..color = const Color(0xFF1A1C2C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRect(Rect.fromLTWH(x, y + bounceOffset, 8, 8), outline);
      }
    }

    // 3. 2.5D Isometric Ring Floor
    final floorY = height * 0.45;
    final ringPaint = Paint()..color = const Color(0xFF2B3864);
    final ringPath = Path()
      ..moveTo(width * 0.1, floorY)
      ..lineTo(width * 0.9, floorY)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(ringPath, ringPaint);

    // Red & Blue Ring Mats
    final matPaint = Paint()..color = const Color(0xFF8B2635);
    final matPath = Path()
      ..moveTo(width * 0.22, floorY + 15)
      ..lineTo(width * 0.78, floorY + 15)
      ..lineTo(width * 0.88, height - 20)
      ..lineTo(width * 0.12, height - 20)
      ..close();
    canvas.drawPath(matPath, matPaint);

    // Ring ropes & turnbuckles
    final ropePaint = Paint()
      ..color = const Color(0xFFF4B41B)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(width * 0.1, floorY), Offset(width * 0.9, floorY), ropePaint);
    canvas.drawLine(Offset(width * 0.1, floorY - 15), Offset(width * 0.9, floorY - 15), ropePaint);

    // 4. Bouncing Pixel Sparring Mini Sprites in Ring
    final spriteBounce = sin(animValue * 4 * pi) * 4.0;
    final pX = width * 0.38;
    final oX = width * 0.62;
    final sY = floorY + (height - floorY) * 0.40;

    // Player sprite mini block
    final playerPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawRect(Rect.fromLTWH(pX, sY + spriteBounce, 14, 22), playerPaint);
    // Stick
    final stickPaint = Paint()
      ..color = const Color(0xFFF4B41B)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(pX + 12, sY + spriteBounce + 6), Offset(pX + 24, sY + spriteBounce - 8), stickPaint);

    // Opponent sprite mini block
    final oppPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRect(Rect.fromLTWH(oX, sY - spriteBounce, 14, 22), oppPaint);
    canvas.drawLine(Offset(oX + 2, sY - spriteBounce + 6), Offset(oX - 10, sY - spriteBounce - 8), stickPaint);
  }

  @override
  bool shouldRepaint(covariant _TitleArenaBackgroundPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

/// Save Slots Modal Dialog
class _SaveSlotsModal extends StatelessWidget {
  final List<SaveSlotInfo> slotsInfo;
  final void Function(int slotIndex, bool isLoad) onSelectSlot;
  final void Function(int slotIndex) onDeleteSlot;

  const _SaveSlotsModal({
    required this.slotsInfo,
    required this.onSelectSlot,
    required this.onDeleteSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RetroBox(
        width: 440,
        title: 'MGA SAVE SLOTS (PUMILI NG SLOT)',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          children: [
            for (int i = 1; i <= 3; i++) ...[
              _buildSlotCard(context, i),
              if (i < 3) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, int slotIndex) {
    final info = slotsInfo.firstWhere(
      (s) => s.slotIndex == slotIndex,
      orElse: () => SaveSlotInfo(slotIndex: slotIndex, hasData: false),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(
          color: info.hasData ? const Color(0xFFF4B41B) : const Color(0xFF475569),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            color: info.hasData ? const Color(0xFFDC2626) : const Color(0xFF334155),
            child: Center(
              child: Text(
                '$slotIndex',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLOT $slotIndex: ${info.hasData ? info.fighterName : "Bakante (Empty)"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  info.summaryText,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (info.hasData) ...[
            RetroButton(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF16A34A),
              onTap: () => onSelectSlot(slotIndex, true),
              child: const Text('LOAD', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
            ),
            const SizedBox(width: 4),
            RetroButton(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: const Color(0xFFDC2626),
              onTap: () => onDeleteSlot(slotIndex),
              child: const Text('DEL', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
            ),
          ] else ...[
            RetroButton(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: const Color(0xFFE6482E),
              onTap: () => onSelectSlot(slotIndex, false),
              child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
            ),
          ],
        ],
      ),
    );
  }
}


