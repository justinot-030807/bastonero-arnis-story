import 'dart:async';
import 'package:flutter/material.dart';
import '../../game/arnis_match_game.dart';
import '../../models/fighter_model.dart';

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
    // Indicator swings back and forth quickly
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

    final indicatorValue = _animController.value; // 0.0 to 1.0
    // Technique stat widens the sweet spot!
    final technique = widget.game.player.combatTechnique;
    final halfZoneWidth = (0.12 + (technique * 0.0035)).clamp(0.12, 0.32);
    final center = 0.50;

    final distFromCenter = (indicatorValue - center).abs();

    bool isPerfect = false;
    bool isSuccess = false;

    if (distFromCenter <= (halfZoneWidth * 0.35)) {
      // Golden Core Bullseye
      isPerfect = true;
      isSuccess = true;
      _resultFeedback = '🔥 ASINTADO! PERFECT HIT! 🔥';
      _feedbackColor = const Color(0xFFFBBF24);
    } else if (distFromCenter <= halfZoneWidth) {
      // Green Target Zone
      isPerfect = false;
      isSuccess = true;
      _resultFeedback = '⚡ SOLID STRIKE! ⚡';
      _feedbackColor = const Color(0xFF4ADE80);
    } else {
      // Missed
      isPerfect = false;
      isSuccess = false;
      _resultFeedback = '❌ SABLAY! (MISSED!) ❌';
      _feedbackColor = const Color(0xFFF87171);
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
      child: Container(
        width: 380,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          border: Border.all(color: const Color(0xFFFACC15), width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            const Text(
              '⚡ SABONG CLINCH: TIMING TEST ⚡',
              style: TextStyle(
                color: Color(0xFFFACC15),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tamaan ang Gitna para sa ${widget.game.playerFighter.style.signatureMove}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 14),

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
                        // Background Bar
                        Container(
                          height: 36,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),

                        // Green Target Zone (Technique-Scaled)
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
                            color: const Color(0xFFFACC15),
                          ),
                        ),

                        // Moving Indicator Pin
                        Positioned(
                          left: (380 - 32) * indicatorVal,
                          child: Container(
                            width: 6,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1.5),
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

            const SizedBox(height: 12),

            // RESULT FEEDBACK OR INSTRUCTION
            if (_hasTapped)
              Text(
                _resultFeedback,
                style: TextStyle(
                  color: _feedbackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              )
            else
              Text(
                'Diskarte Stat (+${technique.toInt()}) pinapalawak ang Gold Sweet Spot!',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),

            const SizedBox(height: 14),

            // TAP BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _hasTapped ? null : _onStrikeAttempt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Text(
                  'PALO NA! (STRIKE / COUNTER)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
