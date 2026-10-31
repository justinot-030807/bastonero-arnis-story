import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';
import '../../models/tournament_model.dart';
import '../retro_ui.dart';

class TournamentModal extends StatefulWidget {
  final GameStateProvider gameState;
  final void Function(TournamentModel tournament, TournamentOpponent opponent) onStartMatch;
  final void Function(TournamentModel tournament)? onOpenBracket;
  final void Function(TournamentModel tournament, TournamentOpponent opponent)? onOpenAnalysis;

  const TournamentModal({
    super.key,
    required this.gameState,
    required this.onStartMatch,
    this.onOpenBracket,
    this.onOpenAnalysis,
  });

  @override
  State<TournamentModal> createState() => _TournamentModalState();
}

class _TournamentModalState extends State<TournamentModal> {
  int _selectedTab = 0; // 0 = School Varsity, 1 = Street Track

  @override
  Widget build(BuildContext context) {
    final fighter = widget.gameState.fighter;
    final currentMonth = widget.gameState.month;

    final schoolTournaments = widget.gameState.tournaments
        .where((t) => t.track == TournamentTrack.schoolTrack)
        .toList();
    final streetTournaments = widget.gameState.tournaments
        .where((t) => t.track == TournamentTrack.streetTrack)
        .toList();

    final activeList = _selectedTab == 0 ? schoolTournaments : streetTournaments;

    return Center(
      child: RetroBox(
        width: 530,
        height: MediaQuery.of(context).size.height * 0.90,
        title: 'PALIGSAHAN AT TOURNAMENTS',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          children: [
            // TRACK SWITCH TABS
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    height: 40,
                    color: _selectedTab == 0 ? const Color(0xFF0284C7) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('SCHOOL VARSITY TRACK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text(
                          'Grado: ${fighter.academics.toStringAsFixed(1)} (Req >= 80)',
                          style: TextStyle(
                            color: fighter.isEligibleForSchoolVarsity ? const Color(0xFF4ADE80) : const Color(0xFFDC2626),
                            fontSize: 8,
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
                    color: _selectedTab == 1 ? const Color(0xFFE6482E) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 1),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('STREET & COMMUNITY TRACK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text('Walang Grado Check - Pera (P)', style: TextStyle(color: Color(0xFFFDE047), fontSize: 8, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // TOURNAMENTS LIST
            Expanded(
              child: ListView.builder(
                itemCount: activeList.length,
                itemBuilder: (context, index) {
                  final t = activeList[index];
                  final isSchool = t.track == TournamentTrack.schoolTrack;
                  final isGradeOk = fighter.isEligibleForSchoolVarsity;
                  final isMonthScheduled = isSchool ? (t.scheduledMonth == currentMonth) : true;
                  final canEnter = isSchool ? (isGradeOk && isMonthScheduled) : true;

                  final activeOpponent = t.bracket?.activePlayerMatch?.fighter2Data ??
                      (t.rounds.isNotEmpty ? t.rounds.first : null);
                  final h2h = activeOpponent != null
                      ? widget.gameState.opponentRecords[activeOpponent.name]
                      : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(
                        color: canEnter ? const Color(0xFFF4B41B) : const Color(0xFF475569),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                t.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              color: canEnter ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              child: Text(
                                canEnter
                                    ? (t.isCompleted ? '[KAMPEON]' : '[BUKAS]')
                                    : (!isGradeOk ? '[SUSPINDIDO <80]' : '[SKED M${t.scheduledMonth}]'),
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(t.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('Premyo: P${t.prizeMoney}', style: const TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('Prestige: +${t.prestigeReward} PTS', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (t.entryFee > 0)
                              Text('Fee: P${t.entryFee}', style: const TextStyle(color: Color(0xFFE6482E), fontSize: 9, fontFamily: 'monospace')),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Opponent Name & H2H record summary
                        if (activeOpponent != null)
                          Row(
                            children: [
                              Text(
                                'Katunggali: ${activeOpponent.name}',
                                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 9, fontFamily: 'monospace', fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 8),
                              if (h2h != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  color: const Color(0xFF0F172A),
                                  child: Text(
                                    'H2H: ${h2h.recordString}',
                                    style: const TextStyle(color: Color(0xFFFDE047), fontSize: 8, fontFamily: 'monospace'),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 8),

                        // BUTTONS: BRACKET LADDER & SURIIN (ANALYSIS) & LABAN
                        Row(
                          children: [
                            // Bracket Ladder Button
                            Expanded(
                              child: RetroButton(
                                height: 30,
                                color: const Color(0xFF0284C7),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  widget.onOpenBracket?.call(t);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PixelSpriteWidget(matrix: PixelArtCatalog.miniTrophy, pixelSize: 1.0),
                                    SizedBox(width: 4),
                                    Text('BRACKETS', style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Analysis Button
                            if (activeOpponent != null)
                              Expanded(
                                child: RetroButton(
                                  height: 30,
                                  color: const Color(0xFF0D9488),
                                  onTap: canEnter
                                      ? () {
                                          Navigator.of(context).pop();
                                          widget.onOpenAnalysis?.call(t, activeOpponent);
                                        }
                                      : null,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PixelSpriteWidget(matrix: PixelArtCatalog.miniWind, pixelSize: 1.0),
                                      SizedBox(width: 4),
                                      Text('SURIIN', style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),

                            // Direct Fight Button
                            Expanded(
                              child: RetroButton(
                                height: 30,
                                color: canEnter ? const Color(0xFFE6482E) : const Color(0xFF475569),
                                onTap: canEnter && activeOpponent != null
                                    ? () {
                                        Navigator.of(context).pop();
                                        widget.onStartMatch(t, activeOpponent);
                                      }
                                    : null,
                                child: const Text('LABAN (FIGHT)', style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
