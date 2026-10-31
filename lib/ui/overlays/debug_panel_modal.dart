// lib/ui/overlays/debug_panel_modal.dart
// Developer / Balance Debug Panel accessed by 5 taps on the date bar (Section 16).

import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/match_engine.dart';
import '../../domain/models/student.dart';
import '../../domain/rng.dart';
import '../../domain/systems/data_loader.dart';
import '../../domain/systems/recruitment_system.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';

class DebugPanelModal extends StatefulWidget {
  final GameStateProvider gameState;

  const DebugPanelModal({super.key, required this.gameState});

  @override
  State<DebugPanelModal> createState() => _DebugPanelModalState();
}

class _DebugPanelModalState extends State<DebugPanelModal> {
  String? _simResult;
  bool _isSimulating = false;

  void _run100SimulatedFights() {
    setState(() {
      _isSimulating = true;
      _simResult = null;
    });

    final state = widget.gameState;
    final student = state.camp.students.isNotEmpty ? state.camp.students.first : null;
    final red = Combatant(
      id: student?.id ?? 'player_test',
      name: student?.name ?? state.fighter.name,
      maxHp: 100.0,
      currentHp: 100.0,
      lakas: student?.lakas ?? state.fighter.power,
      bilis: student?.bilis ?? state.fighter.speed,
      diskarte: student?.diskarte ?? state.fighter.technique,
      salag: student?.salag ?? state.fighter.defense,
      style: student?.style ?? ArnisStyle.soloBaston,
      moves: student?.moves ?? ['abaniko'],
      traits: student?.traits ?? [],
    );

    final blue = Combatant(
      id: 'debug_opp',
      name: 'Ka-Spar (Test Dummy)',
      maxHp: 100.0,
      currentHp: 100.0,
      lakas: 20.0,
      bilis: 20.0,
      diskarte: 18.0,
      salag: 15.0,
      style: ArnisStyle.soloBaston,
      moves: ['abaniko'],
      traits: [],
    );

    int wins = 0;
    int losses = 0;
    int totalRounds = 0;

    for (int i = 0; i < 100; i++) {
      final engine = MatchEngine(
        player: red,
        opponent: blue,
        totalRounds: 3,
        seed: 1000 + i,
      );
      final sim = engine.simulateEntireMatch();
      if (sim.isPlayerWinner) {
        wins++;
      } else {
        losses++;
      }
      totalRounds += engine.currentRound;
    }

    final winRate = (wins / 100.0) * 100.0;
    final avgRounds = (totalRounds / 100.0).toStringAsFixed(1);

    setState(() {
      _isSimulating = false;
      _simResult = '100 SIMULATED MATCHES:\n'
          'Red (${red.name}) vs Blue (${blue.name})\n'
          'Panalo (Wins): $wins | Talo (Losses): $losses\n'
          'Win Rate: ${winRate.toStringAsFixed(1)}% | Avg Rounds: $avgRounds';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 360,
          title: 'DEVELOPER DEBUG PANEL',
          titleTrailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          backgroundColor: const Color(0xFF0F172A),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  color: const Color(0xFF1E293B),
                  child: const Text(
                    'DEVELOPER CHEATS & BALANCE TEST SUITE (Section 16)\nGinamit sa pag-test ng balance at ekonomiya.',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 1. ADD MONEY
                RetroButton(
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    state.debugAddPesos(5000);
                  },
                  child: const Text(
                    '+P5,000 PESOS (Dagdag Pera)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),
                const SizedBox(height: 6),

                // 2. SKIP 1 WEEK
                RetroButton(
                  color: const Color(0xFF0284C7),
                  onTap: () {
                    state.advanceOneWeek();
                    state.recentLog = '[DEBUG] Nilaktawan ang 1 linggo.';
                  },
                  child: const Text(
                    '+1 LINGGO (Skip 1 Week)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),
                const SizedBox(height: 6),

                // 3. SKIP 1 MONTH
                RetroButton(
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    state.debugSkipMonth();
                  },
                  child: const Text(
                    '+1 BUWAN (Skip 4 Weeks)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),
                const SizedBox(height: 6),

                // 4. ADD 5-STAR STUDENT
                RetroButton(
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    if (state.camp.students.length >= state.camp.maxStudents) {
                      state.recentLog = '[DEBUG] Puno na ang kapasidad ng bakuran!';
                      return;
                    }
                    final candidate = RecruitmentSystem.generateCandidate(
                      rng: GameRng(Random().nextInt(100000)),
                      year: state.year,
                      isScholarship: true,
                      maleFirstNames: DataLoader.maleNames,
                      femaleFirstNames: DataLoader.femaleNames,
                      lastNames: DataLoader.lastNames,
                      nicknames: DataLoader.nicknames,
                    );
                    final student = candidate.student;
                    student.lakas = 50.0;
                    student.bilis = 50.0;
                    student.salag = 50.0;
                    student.diskarte = 50.0;
                    student.moves = ['abaniko', 'redonda', 'sinawali'];
                    state.debugAddProdigy(student);
                  },
                  child: const Text(
                    '+5-STAR PRODIGY (Add Top Student)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),
                const SizedBox(height: 6),

                // 5. MAX ACTIVE STUDENT STATS
                RetroButton(
                  color: const Color(0xFFEC4899),
                  onTap: () {
                    state.debugMaxStats();
                  },
                  child: const Text(
                    'MAX STATS 999 (Active Student)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),
                const SizedBox(height: 6),

                // 6. FORCE RANDOM EVENT
                RetroButton(
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    if (DataLoader.eventCatalog.isNotEmpty) {
                      final rng = Random();
                      final ev = DataLoader.eventCatalog[rng.nextInt(DataLoader.eventCatalog.length)];
                      Navigator.of(context).pop();
                      state.debugForceEvent(ev);
                    }
                  },
                  child: const Text(
                    'PUWERSAHIN ANG EVENT (Force Event)',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),
                const SizedBox(height: 6),

                // 7. RUN 100 SIMULATED FIGHTS
                RetroButton(
                  color: const Color(0xFFDC2626),
                  onTap: _isSimulating ? null : _run100SimulatedFights,
                  child: Text(
                    _isSimulating ? 'SIMULATING...' : 'RUN 100 HEADLESS FIGHTS',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Silkscreen'),
                  ),
                ),

                if (_simResult != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: RetroColors.gold),
                    ),
                    child: Text(
                      _simResult!,
                      style: const TextStyle(
                        color: Color(0xFFFDE047),
                        fontSize: 8.5,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
