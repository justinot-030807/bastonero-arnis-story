import 'dart:async';
import 'package:flutter/material.dart';
import '../../game/arnis_match_game.dart';
import '../../models/fighter_model.dart';
import '../retro_ui.dart';

class TimingMiniGameOverlay extends StatefulWidget {
  final ArnisMatchGame game;

  const TimingMiniGameOverlay({super.key, required this.game});

  @override
  State<TimingMiniGameOverlay> createState() => _TimingMiniGameOverlayState();
}

class _TimingMiniGameOverlayState extends State<TimingMiniGameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _autoAttemptTimer;
  bool _hasTapped = false;
  String _resultFeedback = '';
  Color _feedbackColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    // Section 8: "If the player does nothing for 3 s, the engine auto-attempts with 50% effectiveness."
    _autoAttemptTimer = Timer(const Duration(seconds: 3), () {
      if (!_hasTapped && mounted) {
        _resolveTap(0.35, isAuto: true);
      }
    });
  }

  @override
  void dispose() {
    _autoAttemptTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _onStrikeAttempt() {
    if (_hasTapped) return;
    _resolveTap(_animController.value, isAuto: false);
  }

  void _resolveTap(double indicatorValue, {bool isAuto = false}) {
    if (_hasTapped) return;
    _hasTapped = true;
    _autoAttemptTimer?.cancel();
    _animController.stop();

    if (indicatorValue >= 0.45 && indicatorValue <= 0.55) {
      _resultFeedback = '[ASINTADO! PERFECT 2.0x CRIT!]';
      _feedbackColor = const Color(0xFFFDE047);
    } else if (indicatorValue >= 0.30 && indicatorValue <= 0.70) {
      _resultFeedback = isAuto ? '[AUTO-FINISHER! 2.0x PALO]' : '[SOLIDONG FINISHER! 2.0x]';
      _feedbackColor = const Color(0xFF4ADE80);
    } else {
      _resultFeedback = '[SABLAY! MOVE WASTED]';
      _feedbackColor = const Color(0xFFDC2626);
    }

    setState(() {});

    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        widget.game.resolveFinisherTap(tapOffset: indicatorValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final signature = widget.game.playerFighter.style.signatureMove;

    return Center(
      child: RetroBox(
        width: 380,
        title: 'TAMAAN! FINISHER TAP',
        backgroundColor: const Color(0xFF0F172A),
        borderColor: const Color(0xFF1A1C2C),
        bevelColor: const Color(0xFFF59E0B),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PixelSpriteWidget(matrix: PixelArtCatalog.miniBastonIcon, pixelSize: 1.6),
                const SizedBox(width: 8),
                Text(
                  'PUSPOS ANG PUSO: $signature!',
                  style: const TextStyle(
                    color: Color(0xFFFDE047),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tamaan ang Gitnang Gold para sa 2.0x Crit at Screen Flash!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF4ECE1),
                fontSize: 9.5,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),

            // TIMING METER BAR
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final indicatorVal = _animController.value;

                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 36,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: const Color(0xFF1A1C2C), width: 3),
                          ),
                        ),

                        // Green Zone: [0.30..0.70] (40% width)
                        FractionallySizedBox(
                          widthFactor: 0.40,
                          child: Container(
                            height: 36,
                            color: const Color(0xFF16A34A).withValues(alpha: 0.85),
                          ),
                        ),

                        // Gold Bullseye: [0.45..0.55] (10% width)
                        FractionallySizedBox(
                          widthFactor: 0.10,
                          child: Container(
                            height: 36,
                            color: const Color(0xFFF4B41B),
                          ),
                        ),

                        // Moving Indicator Pin
                        Positioned(
                          left: (380 - 48) * indicatorVal,
                          child: Container(
                            width: 6,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF1A1C2C), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            if (_hasTapped)
              Text(
                _resultFeedback,
                style: TextStyle(
                  color: _feedbackColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              )
            else
              const Text(
                'Auto-attempt sa loob ng 3 segundo kapag hindi pinindot.',
                style: TextStyle(
                  color: Color(0xFF8B9BB4),
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                ),
              ),

            const SizedBox(height: 14),

            // TAP BUTTON
            RetroButton(
              height: 44,
              color: const Color(0xFFE6482E),
              onTap: _hasTapped ? null : _onStrikeAttempt,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PixelSpriteWidget(matrix: PixelArtCatalog.iconSpar, pixelSize: 1.2),
                  SizedBox(width: 8),
                  Text(
                    'TAMAAN NA! (TAP)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
