import 'package:flutter/material.dart';
import '../../models/fighter_model.dart';
import '../../models/tournament_model.dart';
import '../../models/opponent_record_model.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';

class TournamentBracketModal extends StatefulWidget {
  final GameStateProvider gameState;
  final TournamentModel tournament;
  final void Function(TournamentModel tourney, TournamentOpponent opp) onOpenAnalysis;
  final void Function(TournamentModel tourney, TournamentOpponent opp) onStartMatch;
  final VoidCallback onBack;

  const TournamentBracketModal({
    super.key,
    required this.gameState,
    required this.tournament,
    required this.onOpenAnalysis,
    required this.onStartMatch,
    required this.onBack,
  });

  @override
  State<TournamentBracketModal> createState() => _TournamentBracketModalState();
}

class _TournamentBracketModalState extends State<TournamentBracketModal> {
  TournamentOpponent? _selectedOpponent;

  @override
  void initState() {
    super.initState();
    _resolveActiveOpponent();
  }

  void _resolveActiveOpponent() {
    final bracket = widget.tournament.bracket;
    if (bracket != null) {
      final active = bracket.activePlayerMatch;
      if (active != null) {
        _selectedOpponent = active.fighter2Data ??
            (widget.tournament.rounds.isNotEmpty
                ? widget.tournament.rounds.first
                : null);
      }
    }
    _selectedOpponent ??= widget.tournament.rounds.isNotEmpty
        ? widget.tournament.rounds.first
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final bracket = t.bracket;
    final matches = bracket?.matches ?? [];

    final activeOpponent = _selectedOpponent ?? (t.rounds.isNotEmpty ? t.rounds.first : null);
    final h2h = activeOpponent != null
        ? (widget.gameState.opponentRecords[activeOpponent.name] ??
            OpponentRecord(
              id: activeOpponent.name,
              name: activeOpponent.name,
              title: activeOpponent.title,
              gymName: activeOpponent.gymName,
              style: activeOpponent.style,
            ))
        : null;

    final isFinished = bracket?.isFinished ?? t.isCompleted;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 500,
          height: MediaQuery.of(context).size.height * 0.90,
          title: 'BRACKETING & MATCHUP LADDER',
          titleTrailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: widget.onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          backgroundColor: const Color(0xFF0F172A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOURNAMENT BANNER & REWARD STRIP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFFF4B41B), width: 1.5),
                ),
                child: Row(
                  children: [
                    const PixelSpriteWidget(matrix: PixelArtCatalog.miniTrophy, pixelSize: 1.5),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              color: Color(0xFFFDE047),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Premyo: P${t.prizeMoney} | Prestige: +${t.prestigeReward} PTS',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: isFinished ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                      child: Text(
                        isFinished ? '[TAPOS NA]' : '[PATULOY]',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2. INTERACTIVE TOURNAMENT BRACKET LADDER VIEW (IMAGE 3 INSPIRATION)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // STAGE TITLE
                      const Text(
                        'SINGLE ELIMINATION CHAMPIONSHIP BRACKET',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // BRACKET NODES ROW (SEMIS -> FINALS)
                      if (matches.length >= 3)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // LEFT COLUMN: SEMI-FINALS
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _buildMatchNode(
                                    matches[0],
                                    isSelected: _selectedOpponent?.name == matches[0].fighter2Name,
                                    onTap: () {
                                      if (matches[0].fighter2Data != null) {
                                        setState(() => _selectedOpponent = matches[0].fighter2Data);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildMatchNode(
                                    matches[1],
                                    isSelected: _selectedOpponent?.name == matches[1].fighter1Name ||
                                        _selectedOpponent?.name == matches[1].fighter2Name,
                                    onTap: () {
                                      if (matches[1].fighter1Data != null) {
                                        setState(() => _selectedOpponent = matches[1].fighter1Data);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // CENTER CONNECTING LINES / ARROW
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('-->', style: TextStyle(color: Color(0xFFF4B41B), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  SizedBox(height: 4),
                                  PixelSpriteWidget(matrix: PixelArtCatalog.miniRing, pixelSize: 1.2),
                                  SizedBox(height: 4),
                                  Text('-->', style: TextStyle(color: Color(0xFFF4B41B), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                ],
                              ),
                            ),

                            // RIGHT COLUMN: CHAMPIONSHIP FINAL
                            Expanded(
                              flex: 5,
                              child: _buildMatchNode(
                                matches[2],
                                isFinals: true,
                                isSelected: _selectedOpponent?.name == matches[2].fighter2Name,
                                onTap: () {
                                  if (matches[2].fighter2Data != null) {
                                    setState(() => _selectedOpponent = matches[2].fighter2Data);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),

                      // 3. OPPONENT DOSSIER & HEAD-TO-HEAD CARD (IMAGE 3 BOTTOM PREVIEW)
                      if (activeOpponent != null && h2h != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Opponent Chibi Avatar
                                  const PixelSpriteWidget(
                                    matrix: PixelArtCatalog.chibiOpponentIdle,
                                    pixelSize: 2.0,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Opponent: ${activeOpponent.name}',
                                          style: const TextStyle(
                                            color: Color(0xFFFDE047),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        Text(
                                          '${activeOpponent.title} | ${activeOpponent.gymName}',
                                          style: const TextStyle(
                                            color: Color(0xFFCBD5E1),
                                            fontSize: 9,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              color: const Color(0xFFE6482E),
                                              child: Text(
                                                activeOpponent.style.displayName.split(' ').first,
                                                style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace'),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Official: ${activeOpponent.officialRecord}',
                                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5, fontFamily: 'monospace'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // HEAD-TO-HEAD SUMMARY BOX
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  border: Border.all(color: const Color(0xFF475569)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildH2hStat('NAKATAPAT', '${h2h.matchesFought}x'),
                                    _buildH2hStat('PANALO', '${h2h.wins}'),
                                    _buildH2hStat('TALO', '${h2h.losses}'),
                                    _buildH2hStat('PEAK DMG', '${h2h.highestDamageDealt}'),
                                    _buildH2hStat('HULI', h2h.lastResult),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // BOTTOM ACTION BUTTONS: SURIIN (EXPERT'S ANALYSIS) & SULONG! LABAN
              Row(
                children: [
                  Expanded(
                    child: RetroButton(
                      height: 40,
                      color: const Color(0xFF0284C7),
                      onTap: activeOpponent != null
                          ? () => widget.onOpenAnalysis(t, activeOpponent)
                          : null,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PixelSpriteWidget(matrix: PixelArtCatalog.miniWind, pixelSize: 1.2),
                          SizedBox(width: 6),
                          Text(
                            "EXPERT'S ANALYSIS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RetroButton(
                      height: 40,
                      color: !isFinished && activeOpponent != null
                          ? const Color(0xFFE6482E)
                          : const Color(0xFF475569),
                      onTap: !isFinished && activeOpponent != null
                          ? () => widget.onStartMatch(t, activeOpponent)
                          : null,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PixelSpriteWidget(matrix: PixelArtCatalog.miniBastonIcon, pixelSize: 1.4),
                          SizedBox(width: 6),
                          Text(
                            'LABAN NA! (FIGHT)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchNode(
    BracketMatch match, {
    bool isFinals = false,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final isDone = match.isCompleted;
    final winner = match.winnerName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
          border: Border.all(
            color: isFinals
                ? const Color(0xFFF4B41B)
                : (isSelected ? const Color(0xFF38BDF8) : const Color(0xFF475569)),
            width: isFinals ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0xFF0284C7), blurRadius: 4)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match.stageName,
                  style: TextStyle(
                    color: isFinals ? const Color(0xFFFDE047) : const Color(0xFF94A3B8),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  color: isDone
                      ? const Color(0xFF16A34A)
                      : (match.isPlayerMatch ? const Color(0xFFE6482E) : const Color(0xFF475569)),
                  child: Text(
                    isDone ? 'TAPOS' : (match.isPlayerMatch ? 'LALABAN' : 'AI'),
                    style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Contender 1
            _buildFighterEntry(
              match.fighter1Name,
              isWinner: isDone && winner == match.fighter1Name,
              isLoser: isDone && winner != null && winner != match.fighter1Name,
            ),
            const SizedBox(height: 2),

            // Contender 2
            _buildFighterEntry(
              match.fighter2Name,
              isWinner: isDone && winner == match.fighter2Name,
              isLoser: isDone && winner != null && winner != match.fighter2Name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFighterEntry(String name, {required bool isWinner, required bool isLoser}) {
    Color textColor = Colors.white;
    if (isWinner) textColor = const Color(0xFF4ADE80);
    if (isLoser) textColor = const Color(0xFF64748B);

    return Row(
      children: [
        Icon(
          isWinner ? Icons.check : (isLoser ? Icons.close : Icons.circle),
          size: 8,
          color: isWinner ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontFamily: 'monospace',
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              decoration: isLoser ? TextDecoration.lineThrough : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildH2hStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 7, fontFamily: 'monospace')),
        const SizedBox(height: 1),
        Text(value, style: const TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}
