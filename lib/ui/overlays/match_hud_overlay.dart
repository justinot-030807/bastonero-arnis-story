import 'package:flutter/material.dart';
import '../../game/arnis_match_game.dart';
import '../../models/fighter_model.dart';
import '../retro_ui.dart';

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
        ValueNotifier(widget.game.matchTimer),
      ]),
      builder: (context, _) {
        final p = widget.game.player;
        final o = widget.game.opponent;
        final engine = widget.game.engine;

        final isBerto = o.fighter.name.contains('Berto');
        final opponentPortrait = isBerto ? PixelArtCatalog.bertoPortrait : PixelArtCatalog.lorenzoPortrait;

        return SafeArea(
          child: Column(
            children: [
              // TOP COMBAT HUD (IMAGE 4 KAIROSOFT BOXING GYM STORY EMULATION)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF1A1C2C), width: 3),
                  ),
                ),
                child: Column(
                  children: [
                    // CORNER GYM TAGS (IMAGE 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Red Corner: ${p.fighter.gymName}',
                          style: const TextStyle(color: Color(0xFFF87171), fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Blue Corner: ${o.fighter.gymName.isNotEmpty ? o.fighter.gymName : "${o.fighter.name.split(' ').first} Club"}',
                          style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    Row(
                      children: [
                        // PLAYER CORNER (RED)
                        const PixelSpriteWidget(
                          matrix: PixelArtCatalog.bayaniPortrait,
                          pixelSize: 2.2,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      p.fighter.name,
                                      style: const TextStyle(
                                        color: Color(0xFFF4ECE1),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: const Color(0xFFDC2626),
                                    child: Text(
                                      p.fighter.style.displayName.split(' ').first,
                                      style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Segmented HP Bar
                              PixelBar(
                                current: p.currentHp,
                                max: p.fighter.maxHp,
                                fillColor: const Color(0xFFDC2626),
                                totalSegments: 12,
                                height: 10,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'HP: ${p.currentHp.toInt()} / ${p.fighter.maxHp.toInt()}',
                                    style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 9, fontFamily: 'monospace'),
                                  ),
                                  if (p.hasBiraAura) ...[
                                    const SizedBox(width: 4),
                                    const Text('+30% LAKAS', style: TextStyle(color: Color(0xFFF87171), fontSize: 7, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  ],
                                  if (p.hasSalagAura) ...[
                                    const SizedBox(width: 4),
                                    const Text('+50% SALAG', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 7, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              // PUSO Gauge
                              Row(
                                children: [
                                  Expanded(
                                    child: PixelBar(
                                      current: engine.player.pusoMeter,
                                      max: 100.0,
                                      fillColor: const Color(0xFFF59E0B),
                                      totalSegments: 10,
                                      height: 5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    engine.player.pusoMeter >= 100.0
                                        ? 'TAMAAN!'
                                        : 'PUSO: ${engine.player.pusoMeter.toInt()}%',
                                    style: TextStyle(
                                      color: engine.player.pusoMeter >= 100.0
                                          ? const Color(0xFFFDE047)
                                          : const Color(0xFFF59E0B),
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // CENTRAL DIGITAL PIXEL ROUND TIMER (IMAGE 4)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            border: Border.all(color: const Color(0xFFF4B41B), width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ROUND ${engine.currentRound}/${engine.totalRounds}',
                                style: const TextStyle(color: Color(0xFFF4B41B), fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.game.matchTimer.toInt().toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Color(0xFFFDE047),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: const Color(0xFF2563EB),
                                    child: Text(
                                      o.fighter.style.displayName.split(' ').first,
                                      style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      o.fighter.name,
                                      style: const TextStyle(
                                        color: Color(0xFFF4ECE1),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Segmented HP Bar
                              PixelBar(
                                current: o.currentHp,
                                max: o.fighter.maxHp,
                                fillColor: const Color(0xFF38BDF8),
                                totalSegments: 12,
                                height: 10,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'HP: ${o.currentHp.toInt()} / ${o.fighter.maxHp.toInt()}',
                                style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 9, fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 2),
                              // Opponent Action Gauge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'AKSYON: ${engine.opponent.actionMeter.toInt().clamp(0, 100)}%',
                                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 7.5, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    width: 50,
                                    child: PixelBar(
                                      current: engine.opponent.actionMeter.clamp(0.0, 100.0),
                                      max: 100.0,
                                      fillColor: const Color(0xFF38BDF8),
                                      totalSegments: 6,
                                      height: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PixelSpriteWidget(
                          matrix: opponentPortrait,
                          pixelSize: 2.2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // FLOATING COMBO BADGE (IMAGE 4)
              if (widget.game.playerComboCount >= 2)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    border: Border.all(color: const Color(0xFFFEF08A), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                    ],
                  ),
                  child: Text(
                    '${widget.game.playerComboCount}-HIT COMBO!',
                    style: const TextStyle(
                      color: Color(0xFFFEF08A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

              const Spacer(),

              // BOTTOM COMBAT PANEL: LIVE ANNOUNCER SCROLLER + 4-STAT CARDS + GIGIL + COMMANDS
              Container(
                color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  children: [
                    // LIVE ANNOUNCER SCROLLING LOG BOX (IMAGE 4 ANNOUNCER TICKER)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        border: Border.all(color: const Color(0xFF475569)),
                      ),
                      child: Text(
                        widget.game.announcerLogs.isNotEmpty
                            ? 'Announcer: ${widget.game.announcerLogs.last}'
                            : 'Announcer: Handa na ang labanan!',
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // 4-STAT COMPARISON BREAKDOWN WITH MINI PIXEL ICONS (IMAGE 4 BOTTOM STATS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox(PixelArtCatalog.miniMuscle, 'LAKAS', p.combatPower.toInt(), o.combatPower.toInt()),
                        _buildStatBox(PixelArtCatalog.miniShoe, 'BILIS', p.combatSpeed.toInt(), o.combatSpeed.toInt()),
                        _buildStatBox(PixelArtCatalog.miniBastonIcon, 'DISKARTE', p.combatTechnique.toInt(), o.combatTechnique.toInt()),
                        _buildStatBox(PixelArtCatalog.miniTrunks, 'SALAG', p.combatDefense.toInt(), o.combatDefense.toInt()),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // COACH GIGIL METER
                    Row(
                      children: [
                        const Text(
                          'COACH GIGIL: ',
                          style: TextStyle(color: Color(0xFFF4B41B), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                        Expanded(
                          child: PixelBar(
                            current: widget.game.coachGigilMeter,
                            max: 100.0,
                            fillColor: const Color(0xFFE6482E),
                            totalSegments: 14,
                            height: 9,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.game.coachGigilMeter.toInt()}%',
                          style: const TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 3 TACTILE ACTION BUTTONS (ZERO EMOJIS!)
                    Row(
                      children: [
                        Expanded(
                          child: RetroButton(
                            height: 36,
                            color: const Color(0xFFE6482E),
                            onTap: widget.game.coachGigilMeter >= 35.0 && !widget.game.isMatchOver
                                ? () => setState(() => widget.game.shoutBira())
                                : null,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('BIRA!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                Text('+30% Lakas (35%)', style: TextStyle(color: Color(0xFFFDE047), fontSize: 7, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RetroButton(
                            height: 36,
                            color: const Color(0xFF0284C7),
                            onTap: widget.game.coachGigilMeter >= 30.0 && !widget.game.isMatchOver
                                ? () => setState(() => widget.game.shoutSalag())
                                : null,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('SALAG!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                Text('+50% Salag (30%)', style: TextStyle(color: Color(0xFFFDE047), fontSize: 7, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RetroButton(
                            height: 36,
                            color: const Color(0xFFF4B41B),
                            onTap: widget.game.coachGigilMeter >= 45.0 && !widget.game.isMatchOver
                                ? () => setState(() => widget.game.shoutDiskarte())
                                : null,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('DISKARTE!', style: TextStyle(color: Color(0xFF1A1C2C), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                Text('Sabong Lock (45%)', style: TextStyle(color: Color(0xFF1A1C2C), fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              ],
                            ),
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

  Widget _buildStatBox(List<String> iconMatrix, String label, int playerVal, int oppVal) {
    final color = playerVal > oppVal
        ? const Color(0xFF4ADE80) // Advantage Green
        : (playerVal < oppVal
            ? const Color(0xFFEF4444) // Disadvantage Red
            : const Color(0xFFFDE047)); // Equal Yellow

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelSpriteWidget(matrix: iconMatrix, pixelSize: 1.1),
          const SizedBox(width: 4),
          Text(
            '$playerVal vs $oppVal',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
