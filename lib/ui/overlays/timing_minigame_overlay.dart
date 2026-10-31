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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onStrikeAttempt() {
    if (_hasTapped) return;
    _hasTapped = true;
    _animController.stop();

    final indicatorValue = _animController.value;
    final technique = widget.game.player.combatTechnique;
    final halfZoneWidth = (0.12 + (technique * 0.0035)).clamp(0.12, 0.32);
    const center = 0.50;

    final distFromCenter = (indicatorValue - center).abs();

    bool isPerfect = false;
    bool isSuccess = false;

    if (distFromCenter <= (halfZoneWidth * 0.35)) {
      isPerfect = true;
      isSuccess = true;
      _resultFeedback = '[ASINTADO! PERFECT COUNTER!]';
      _feedbackColor = const Color(0xFFFDE047);
    } else if (distFromCenter <= halfZoneWidth) {
      isPerfect = false;
      isSuccess = true;
      _resultFeedback = '[SOLIDONG PALO! GOOD HIT!]';
      _feedbackColor = const Color(0xFF4ADE80);
    } else {
      isPerfect = false;
      isSuccess = false;
      _resultFeedback = '[SABLAY! COUNTERED BY OPPONENT!]';
      _feedbackColor = const Color(0xFFDC2626);
    }

    setState(() {});

    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        widget.game.resolveClinchMiniGame(
          isPerfect: isPerfect,
          isSuccess: isSuccess,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final technique = widget.game.player.combatTechnique;
    final halfZoneWidth = (0.12 + (technique * 0.0035)).clamp(0.12, 0.32);
    final totalZoneFactor = halfZoneWidth * 2;

    return Center(
      child: RetroBox(
        width: 380,
        title: 'SABONG CLINCH: TIMING TEST',
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tamaan ang Gitnang Gold para sa ${widget.game.playerFighter.style.signatureMove}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF4ECE1),
                fontSize: 10,
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

                        // Green Target Zone
                        FractionallySizedBox(
                          widthFactor: totalZoneFactor,
                          child: Container(
                            height: 36,
                            color: const Color(0xFF16A34A).withValues(alpha: 0.85),
                          ),
                        ),

                        // Golden Center Bullseye
                        FractionallySizedBox(
                          widthFactor: totalZoneFactor * 0.35,
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
              Text(
                'Diskarte Stat (+${technique.toInt()}) pinapalawak ang Gold Sweet Spot!',
                style: const TextStyle(
                  color: Color(0xFF8B9BB4),
                  fontSize: 9,
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
                    'HATAW NA! (STRIKE / COUNTER)',
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
