import 'package:flutter/material.dart';
import '../../game/arnis_match_game.dart';

class MatchResultOverlay extends StatelessWidget {
  final ArnisMatchGame game;
  final VoidCallback onDismiss;

  const MatchResultOverlay({
    super.key,
    required this.game,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final won = game.isPlayerWinner;
    final tournament = game.tournament;
    final prizeMoney = won ? (tournament?.prizeMoney ?? 300) : ((tournament?.prizeMoney ?? 300) * 0.15).round();
    final prestige = won ? (tournament?.prestigeReward ?? 10) : 2;

    return Center(
      child: Container(
        width: 360,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(
            color: won ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TITLE
            Text(
              won ? '🏆 TAPOS ANG LABAN: PANALO! 🏆' : '💀 TAPOS ANG LABAN: TALO 💀',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: won ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // MATCH DETAILS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Column(
                children: [
                  _buildStatRow('Labanan:', tournament?.title ?? 'Friendly Sparring'),
                  const Divider(color: Color(0xFF475569)),
                  _buildStatRow('Lakas ng Palo:', won ? 'Magaling at Asintado!' : 'Kulang sa Salag!'),
                  const Divider(color: Color(0xFF475569)),
                  _buildStatRow('Premyong Salapi:', '₱$prizeMoney', valueColor: const Color(0xFFFBBF24)),
                  const Divider(color: Color(0xFF475569)),
                  _buildStatRow('Prestige Rank:', '+$prestige ★', valueColor: const Color(0xFF60A5FA)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: won ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Text(
                  'BUMALIK SA GYM (CONTINUE)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color valueColor = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
