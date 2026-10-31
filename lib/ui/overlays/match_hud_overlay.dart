import 'package:flutter/material.dart';
import '../../game/arnis_match_game.dart';

class MatchHudOverlay extends StatefulWidget {
  final ArnisMatchGame game;

  const MatchHudOverlay({super.key, required this.game});

  @override
  State<MatchHudOverlay> createState() => _MatchHudOverlayState();
}

class _MatchHudOverlayState extends State<MatchHudOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        // Continuously update HUD based on game ticks
        ValueNotifier(widget.game.matchTimer),
      ]),
      builder: (context, _) {
        final p = widget.game.player;
        final o = widget.game.opponent;

        final playerHpPct = (p.currentHp / p.fighter.maxHp).clamp(0.0, 1.0);
        final opponentHpPct = (o.currentHp / o.fighter.maxHp).clamp(0.0, 1.0);
        final gigilPct = (widget.game.coachGigilMeter / 100.0).clamp(0.0, 1.0);

        return SafeArea(
          child: Column(
            children: [
              // TOP BAR: HP BARS & ROUND TIMER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withValues(alpha: 0.7),
                child: Row(
                  children: [
                    // PLAYER CORNER (RED)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                color: const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p.fighter.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // HP Bar
                          Stack(
                            children: [
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: playerHpPct,
                                child: Container(
                                  height: 14,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HP: ${p.currentHp.toInt()} / ${p.fighter.maxHp.toInt()}',
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ROUND TIMER
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        border: Border.all(color: const Color(0xFFFACC15), width: 2),
                      ),
                      child: Text(
                        widget.game.matchTimer.toInt().toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Color(0xFFFACC15),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),

                    // OPPONENT CORNER (BLUE)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  o.fighter.name,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 10,
                                height: 10,
                                color: const Color(0xFF3B82F6),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // HP Bar
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: opponentHpPct,
                                child: Container(
                                  height: 14,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HP: ${o.currentHp.toInt()} / ${o.fighter.maxHp.toInt()}',
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // BOTTOM COACH AURA COMMAND BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.black.withValues(alpha: 0.85),
                child: Column(
                  children: [
                    // GIGIL / AURA METER
                    Row(
                      children: [
                        const Text(
                          'COACH GIGIL:',
                          style: TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: gigilPct,
                                child: Container(
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFEAB308), Color(0xFFEF4444)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.game.coachGigilMeter.toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 3 COACH SHOUT COMMAND BUTTONS
                    Row(
                      children: [
                        // BIRA!
                        Expanded(
                          child: _buildCoachButton(
                            title: 'BIRA! 🔥',
                            subtitle: '+30% Lakas (35%)',
                            color: const Color(0xFFEA580C),
                            isEnabled: widget.game.coachGigilMeter >= 35.0 && !widget.game.isMatchOver,
                            onTap: () {
                              setState(() {
                                widget.game.shoutBira();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // SALAG!
                        Expanded(
                          child: _buildCoachButton(
                            title: 'SALAG! 🛡️',
                            subtitle: '+50% Block (30%)',
                            color: const Color(0xFF0284C7),
                            isEnabled: widget.game.coachGigilMeter >= 30.0 && !widget.game.isMatchOver,
                            onTap: () {
                              setState(() {
                                widget.game.shoutSalag();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // DISKARTE!
                        Expanded(
                          child: _buildCoachButton(
                            title: 'DISKARTE! ⚡',
                            subtitle: 'Lock & Clinch (45%)',
                            color: const Color(0xFFCA8A04),
                            isEnabled: widget.game.coachGigilMeter >= 45.0 && !widget.game.isMatchOver,
                            onTap: () {
                              setState(() {
                                widget.game.shoutDiskarte();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoachButton({
    required String title,
    required String subtitle,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? color : const Color(0xFF334155),
          border: Border.all(
            color: isEnabled ? Colors.white : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isEnabled ? const Color(0xFFFEF08A) : Colors.grey[500],
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
