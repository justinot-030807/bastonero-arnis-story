// lib/ui/overlays/focus_tap_modal.dart
// Interactive Focus Tap Timing Mini-game for weekly student training boosts.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/focus_tap.dart';
import '../../domain/models/student.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';

class FocusTapModal extends StatefulWidget {
  final GameStateProvider gameState;
  final Student student;
  final VoidCallback? onCompleted;

  const FocusTapModal({
    super.key,
    required this.gameState,
    required this.student,
    this.onCompleted,
  });

  @override
  State<FocusTapModal> createState() => _FocusTapModalState();
}

class _FocusTapModalState extends State<FocusTapModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FocusTapResult? _result;
  bool _tapped = false;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_tapped) return;
    _controller.stop();
    final pos = _controller.value;
    final res = FocusTapResult.evaluate(pos);

    setState(() {
      _tapped = true;
      _result = res;
    });

    widget.gameState.recordFocusTap(widget.student.id, res);

    _closeTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        widget.onCompleted?.call();
        Navigator.of(context).pop(res);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RetroBox(
        width: 320,
        title: 'FOCUS TAP (KONSENTRASYON)',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: const Color(0xFF0F172A),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pagsasanay ni ${widget.student.name}',
                style: const TextStyle(
                  color: RetroColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Silkscreen',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pindutin ang TUMAMA kapag nasa gitna ang guhit para sa +25% hanggang +40% dagdag galing!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 7.5,
                  fontFamily: 'Silkscreen',
                ),
              ),
              const SizedBox(height: 14),

              // TIMING GAUGE
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pos = _tapped && _result != null
                      ? _result!.position
                      : _controller.value;

                  return Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: const Color(0xFF1A1C2C), width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Zone 1: Good Zone (0.35 .. 0.65)
                        Positioned(
                          left: 280 * 0.35,
                          width: 280 * 0.30,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.5),
                          ),
                        ),
                        // Zone 2: Perfect Center Bullseye (0.45 .. 0.55)
                        Positioned(
                          left: 280 * 0.45,
                          width: 280 * 0.10,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        // Zone markers labels
                        const Positioned(
                          top: 2,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              '+40% SWAK',
                              style: TextStyle(
                                color: Color(0xFF1A1C2C),
                                fontSize: 6.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Silkscreen',
                              ),
                            ),
                          ),
                        ),
                        // Sliding Indicator
                        Positioned(
                          left: (280 - 6) * pos,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: _tapped ? Colors.white : const Color(0xFFEF4444),
                              border: Border.all(color: const Color(0xFF1A1C2C), width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // RESULT BADGE
              if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _result!.rating == FocusTapRating.perfect
                        ? const Color(0xFFF59E0B)
                        : (_result!.rating == FocusTapRating.good
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626)),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    _result!.rating.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Silkscreen',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // TAP BUTTON
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  height: 36,
                  color: _tapped ? const Color(0xFF475569) : const Color(0xFFE6482E),
                  onTap: _tapped ? null : _handleTap,
                  child: Text(
                    _tapped ? 'NAITAKDA NA!' : 'TUMAMA NGAYON!',
                    style: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'Silkscreen',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
