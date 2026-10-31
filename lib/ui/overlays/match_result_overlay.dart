import 'package:flutter/material.dart';
import '../../domain/match_engine.dart';
import '../../game/arnis_match_game.dart';
import '../retro_ui.dart';

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

    final p = game.engine.player;
    final o = game.engine.opponent;
    final reason = game.engine.endReason;
    final reasonText = reason == MatchEndReason.knockout
        ? 'KNOCKOUT (KO)'
        : (reason == MatchEndReason.refereeStoppage ? 'REFEREE STOPPAGE (TKO)' : 'UNANIMOUS DECISION');

    final accuracy = p.strikesAttempted > 0
        ? ((p.strikesLanded / p.strikesAttempted) * 100).toInt()
        : 0;

    return Center(
      child: SingleChildScrollView(
        child: RetroBox(
          width: 380,
          title: won ? 'TAPOS ANG LABAN: PANALO!' : 'TAPOS ANG LABAN: TALO',
          backgroundColor: const Color(0xFF0F172A),
          borderColor: const Color(0xFF1A1C2C),
          bevelColor: won ? const Color(0xFF4ADE80) : const Color(0xFFDC2626),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PixelSpriteWidget(
                    matrix: won ? PixelArtCatalog.iconLaban : PixelArtCatalog.iconSpar,
                    pixelSize: 2.2,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    won ? '[KAMPEON SA LABAN]' : '[HINDI PINALAD SA RING]',
                    style: TextStyle(
                      color: won ? const Color(0xFFFDE047) : const Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: won ? const Color(0xFF166534) : const Color(0xFF991B1B),
                child: Text(
                  reasonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // BOUT STATISTICS BREAKDOWN
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Labanan:', tournament?.title ?? 'Friendly Sparring'),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow(
                      'Hataw (Landed/Tries):',
                      '${p.strikesLanded}/${p.strikesAttempted} ($accuracy%) vs ${o.strikesLanded}/${o.strikesAttempted}',
                    ),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Nasalag na Palo (Blocks):', '${p.strikesBlocked} vs ${o.strikesBlocked}'),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Kritikal na Tama:', '${p.critsLanded} vs ${o.critsLanded}'),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Pinakamataas na Combo:', '${p.highestCombo}-Hit Combo'),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow(
                      'Pinakamalakas na Palo:',
                      '${p.maxDamageSingleHit.toStringAsFixed(1)} DMG',
                      valueColor: const Color(0xFFFDE047),
                    ),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Kabuuang Pinsala (Total):', '${p.totalDamageDealt.toStringAsFixed(1)} DMG'),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Premyong Salapi:', 'P$prizeMoney', valueColor: const Color(0xFFFDE047)),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Prestige Rank:', '+$prestige PTS', valueColor: const Color(0xFF38BDF8)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              RetroButton(
                height: 42,
                color: won ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                onTap: onDismiss,
                child: const Text(
                  'BUMALIK SA GYM (CONTINUE)',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
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
          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 9.5, fontFamily: 'monospace'),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
