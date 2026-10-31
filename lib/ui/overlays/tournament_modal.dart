import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';
import '../../models/tournament_model.dart';

class TournamentModal extends StatefulWidget {
  final GameStateProvider gameState;
  final void Function(TournamentModel tournament, TournamentOpponent opponent) onStartMatch;

  const TournamentModal({
    super.key,
    required this.gameState,
    required this.onStartMatch,
  });

  @override
  State<TournamentModal> createState() => _TournamentModalState();
}

class _TournamentModalState extends State<TournamentModal> {
  int _selectedTab = 0; // 0 = School Track, 1 = Street Track

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
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: const Color(0xFFF59E0B), width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'PALIGSAHAN (TOURNAMENT ARENA)',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // TRACK SWITCHER TABS
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                        border: Border.all(
                          color: _selectedTab == 0 ? Colors.white : const Color(0xFF475569),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SCHOOL VARSITY TRACK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Grado: ${fighter.academics.toStringAsFixed(1)} (Req >= 80.0)',
                            style: TextStyle(
                              color: fighter.isEligibleForSchoolVarsity
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFCA5A5),
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
                        border: Border.all(
                          color: _selectedTab == 1 ? Colors.white : const Color(0xFF475569),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'STREET & COMMUNITY TRACK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'No Grade Check • Fast Cash (₱)',
                            style: TextStyle(
                              color: Color(0xFFFDE047),
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // TOURNAMENT CARDS
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: activeList.length,
                itemBuilder: (context, index) {
                  final t = activeList[index];
                  final isSchool = t.track == TournamentTrack.schoolTrack;
                  final isGradeOk = fighter.isEligibleForSchoolVarsity;
                  final isMonthScheduled = isSchool ? (t.scheduledMonth == currentMonth) : true;
                  final canEnter = isSchool ? (isGradeOk && isMonthScheduled) : true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(
                        color: canEnter ? const Color(0xFFF59E0B) : const Color(0xFF475569),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: canEnter ? const Color(0xFF16A34A) : const Color(0xFF991B1B),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                canEnter
                                    ? 'OPEN NOW'
                                    : (!isGradeOk
                                        ? 'SUSPENDED (<80)'
                                        : 'SCHEDULED (M${t.scheduledMonth})'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.description,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                        ),
                        const SizedBox(height: 8),

                        // REWARDS & DETAILS
                        Row(
                          children: [
                            Text(
                              'Prize: ₱${t.prizeMoney}',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Prestige: +${t.prestigeReward} ★',
                              style: const TextStyle(
                                color: Color(0xFF60A5FA),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Spacer(),
                            if (t.entryFee > 0)
                              Text(
                                'Fee: ₱${t.entryFee}',
                                style: const TextStyle(
                                  color: Color(0xFFF87171),
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // OPPONENTS PREVIEW & ENTER BUTTON
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Rival: ${t.rounds.last.name}',
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: canEnter
                                  ? () {
                                      Navigator.of(context).pop();
                                      widget.onStartMatch(t, t.rounds.first);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Text(
                                'LABAN (FIGHT)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
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
