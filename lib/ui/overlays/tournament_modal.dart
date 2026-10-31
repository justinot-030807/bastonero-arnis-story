import 'package:flutter/material.dart';
import '../../domain/models/student.dart';
import '../../models/tournament_model.dart';
import '../../providers/game_state_provider.dart';
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
  int _selectedTab = 0; // 0 = Community Track, 1 = School Varsity Track

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final currentStudent = state.activeStudent;
    final currentMonth = state.month;

    final communityTournaments = state.tournaments
        .where((t) => t.track == TournamentTrack.streetTrack)
        .toList();
    final schoolTournaments = state.tournaments
        .where((t) => t.track == TournamentTrack.schoolTrack)
        .toList();

    final activeList = _selectedTab == 0 ? communityTournaments : schoolTournaments;

    return Center(
      child: RetroBox(
        width: 530,
        height: MediaQuery.of(context).size.height * 0.92,
        title: 'PALIGSAHAN AT TOURNAMENTS',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. STUDENT REPRESENTATIVE SELECTOR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'REPRESENTATIVE ARNISADOR:',
                        style: TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'Scholarship: ${state.scholarshipPoints} PTS',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.students.map((student) {
                        final isSelected = student.id == currentStudent.id;
                        final isEligible = student.isVarsityEligible && student.status != StudentStatus.injured;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              state.setActiveStudent(student.id);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFDE047) : const Color(0xFF334155),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PixelSpriteWidget(
                                    matrix: isSelected
                                        ? PixelArtCatalog.bayaniPortrait
                                        : PixelArtCatalog.lorenzoPortrait,
                                    pixelSize: 1.0,
                                  ),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      Text(
                                        'G${student.grade} (${student.gradePercent.toStringAsFixed(1)}%) ${isEligible ? "[PASADO]" : "[BAGSAK]"}',
                                        style: TextStyle(
                                          color: isEligible ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
                                          fontSize: 7.5,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. TRACK SWITCH TABS
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    height: 38,
                    color: _selectedTab == 0 ? const Color(0xFFE6482E) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('KOMUNIDAD (COMMUNITY TRACK)', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text('Walang Grado Check - Premyong Pera', style: TextStyle(color: Color(0xFFFDE047), fontSize: 7.5, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RetroButton(
                    height: 38,
                    color: _selectedTab == 1 ? const Color(0xFF0284C7) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('PAARALAN (SCHOOL VARSITY)', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text(
                          'Grado Req >= 75% | Scholarship PTS',
                          style: TextStyle(
                            color: currentStudent.isVarsityEligible ? const Color(0xFF4ADE80) : const Color(0xFFDC2626),
                            fontSize: 7.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 3. TOURNAMENTS LIST
            Expanded(
              child: ListView.builder(
                itemCount: activeList.length,
                itemBuilder: (context, index) {
                  final t = activeList[index];
                  final isSchool = t.track == TournamentTrack.schoolTrack;

                  // Eligibility checks
                  final hasGrades = isSchool ? currentStudent.isVarsityEligible : true;
                  final isHealthy = currentStudent.status != StudentStatus.injured;
                  final hasRankFame = state.prestige >= (t.prestigeReward * 5); // soft threshold
                  final canAfford = state.pesos >= (t.entryFee + t.travelCost);
                  final isMonthScheduled = isSchool ? (t.scheduledMonth == currentMonth) : true;

                  final canEnter = hasGrades && isHealthy && canAfford && hasRankFame;

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
                                t.isCompleted
                                    ? '[KAMPEON]'
                                    : (!hasGrades
                                        ? '[BAGSAK <75%]'
                                        : (!canAfford
                                            ? '[KULANG PERA]'
                                            : (!hasRankFame
                                                ? '[KULANG FAME]'
                                                : (!isMonthScheduled
                                                    ? '[SKED M${t.scheduledMonth}]'
                                                    : '[BUKAS]')))),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t.description,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                        ),
                        const SizedBox(height: 6),

                        // Financial & Reward Stats Row
                        Row(
                          children: [
                            Text(
                              'Premyo: P${t.prizeMoney}',
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Prestige: +${t.prestigeReward}',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (t.scholarshipPoints > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Scholar: +${t.scholarshipPoints}',
                                style: const TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 9.5,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (t.entryFee > 0 || t.travelCost > 0)
                              Text(
                                'Gastos: P${t.entryFee + t.travelCost}',
                                style: const TextStyle(
                                  color: Color(0xFFF87171),
                                  fontSize: 8.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Opponent Name & H2H record summary
                        if (activeOpponent != null)
                          Row(
                            children: [
                              Text(
                                'Katunggali: ${activeOpponent.name}',
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (h2h != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  color: const Color(0xFF0F172A),
                                  child: Text(
                                    'H2H: ${h2h.recordString}',
                                    style: const TextStyle(
                                      color: Color(0xFFFDE047),
                                      fontSize: 8,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 8),

                        // ACTION BUTTONS: BRACKETS & SURIIN & LABAN
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
