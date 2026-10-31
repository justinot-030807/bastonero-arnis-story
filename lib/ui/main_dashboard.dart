import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/facility_model.dart';
import '../models/fighter_model.dart';
import '../models/tournament_model.dart';
import '../providers/game_state_provider.dart';
import '../game/arnis_match_game.dart';
import '../game/components/arena_component.dart';
import 'overlays/match_hud_overlay.dart';
import 'overlays/timing_minigame_overlay.dart';
import 'overlays/match_result_overlay.dart';
import 'overlays/training_modal.dart';
import 'overlays/tournament_modal.dart';
import 'overlays/gym_builder_modal.dart';
import 'overlays/story_dialog_modal.dart';
import 'overlays/shop_modal.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  ArnisMatchGame? _activeGame;

  void _startMatch({
    required FighterModel player,
    required FighterModel opponent,
    TournamentModel? tournament,
    ArenaType arenaType = ArenaType.purokLupa,
  }) {
    final game = ArnisMatchGame(
      playerFighter: player,
      opponentFighter: opponent,
      tournament: tournament,
      arenaType: arenaType,
      onMatchEnded: (won) {
        final provider = Provider.of<GameStateProvider>(context, listen: false);
        if (tournament != null) {
          provider.completeTournament(tournament, won);
        } else {
          provider.advanceOneWeek(
            actionSummary: won
                ? 'Nanalo sa Friendly Sparring! +XP at karanasan!'
                : 'Natapos ang Friendly Sparring. May natutunang bagong diskarte!',
          );
        }
      },
    );

    setState(() {
      _activeGame = game;
    });
  }

  void _exitMatch() {
    setState(() {
      _activeGame = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, _) {
        // If an active Flame match is underway, render GameWidget with overlays
        if (_activeGame != null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: GameWidget<ArnisMatchGame>(
              game: _activeGame!,
              overlayBuilderMap: {
                'matchHud': (ctx, game) => MatchHudOverlay(game: game),
                'timingMinigame': (ctx, game) => TimingMiniGameOverlay(game: game),
                'matchResult': (ctx, game) => MatchResultOverlay(
                      game: game,
                      onDismiss: _exitMatch,
                    ),
              },
            ),
          );
        }

        // Otherwise render the Kairosoft-style Gym & Career Sim Dashboard
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // TOP BAR: CALENDAR, WEALTH, & STATUS
                    _buildTopHud(context, gameState),

                    // KAIROSOFT NEWS / NOTIFICATION TICKER
                    _buildTicker(gameState),

                    // MAIN SCROLLABLE CONTENT (GYM + FIGHTER PROFILE)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ACTIVE SYNERGY COMBOS
                            if (gameState.activeSynergies.isNotEmpty)
                              _buildSynergyStrip(gameState),

                            // KAIROSOFT BACKYARD GYM GRID
                            _buildGymSection(context, gameState),
                            const SizedBox(height: 14),

                            // FIGHTER ATTRIBUTES & CAREER PROFILE
                            _buildFighterProfileSection(context, gameState),
                          ],
                        ),
                      ),
                    ),

                    // BOTTOM ACTION BAR
                    _buildBottomActionBar(context, gameState),
                  ],
                ),
              ),

              // STORY EVENT DIALOG MODAL (IF TRIGGERED)
              if (gameState.activeDialogueEvent != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.75),
                  child: StoryDialogModal(
                    event: gameState.activeDialogueEvent!,
                    onDismiss: gameState.dismissActiveDialogue,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // TOP HUD
  Widget _buildTopHud(BuildContext context, GameStateProvider state) {
    final fighter = state.fighter;
    final isVarsityOk = fighter.isEligibleForSchoolVarsity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF38BDF8), width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Calendar Date Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFFFACC15), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Y${state.year} • Wk${state.week} • ${state.currentMonthName}',
                  style: const TextStyle(
                    color: Color(0xFFFACC15),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const Spacer(),

              // Currency
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFBBF24), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '₱${state.pesos}',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (state.totalPassiveWeeklyPesos > 0)
                    Text(
                      ' (+₱${state.totalPassiveWeeklyPesos}/w)',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 9, fontFamily: 'monospace'),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Prestige
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFF60A5FA), size: 16),
                  const SizedBox(width: 2),
                  Text(
                    '${state.prestige}',
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // STAMINA & ACADEMIC GRADE BAR
          Row(
            children: [
              // Stamina
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    const Text(
                      'HANGIN (STA):',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 10, fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              border: Border.all(color: const Color(0xFF475569)),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (fighter.stamina / fighter.maxStamina).clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              color: const Color(0xFF06B6D4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${fighter.stamina.toInt()}',
                      style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Academics Grado
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    const Text(
                      'GRADO:',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 10, fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVarsityOk ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '${fighter.academics.toStringAsFixed(1)}% (${isVarsityOk ? 'Varsity' : 'Suspended'})',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TICKER
  Widget _buildTicker(GameStateProvider state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Color(0xFF38BDF8), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              state.recentLog,
              style: const TextStyle(
                color: Color(0xFFE0F2FE),
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // SYNERGY STRIP
  Widget _buildSynergyStrip(GameStateProvider state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 16),
              SizedBox(width: 4),
              Text(
                'AKTIBONG SYNERGY COMBOS:',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: state.activeSynergies.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFFFBBF24)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '⚡ ${s.title}',
                  style: const TextStyle(
                    color: Color(0xFFFDE047),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // BACKYARD GYM GRID
  Widget _buildGymSection(BuildContext context, GameStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(color: const Color(0xFF475569), width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.home_filled, color: Color(0xFF4ADE80), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'BAKURAN TRAINING CAMP (SLOTS)',
                    style: TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              if (state.maxSlots == 4)
                TextButton(
                  onPressed: state.pesos >= 1800 ? () => state.expandGymSlots() : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    backgroundColor: const Color(0xFF0F172A),
                  ),
                  child: const Text(
                    'EXPAND (₱1800)',
                    style: TextStyle(color: Color(0xFFFBBF24), fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // GRID OF SLOTS
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.maxSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final facility = state.slots[index];
              return _buildGymSlot(context, state, index, facility);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGymSlot(
    BuildContext context,
    GameStateProvider state,
    int slotIndex,
    FacilityModel? facility,
  ) {
    final isOccupied = facility != null;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => GymBuilderModal(gameState: state, slotIndex: slotIndex),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isOccupied ? const Color(0xFF0F172A) : const Color(0xFF0F172A).withValues(alpha: 0.4),
          border: Border.all(
            color: isOccupied ? const Color(0xFF22C55E) : const Color(0xFF475569),
            width: isOccupied ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isOccupied) ...[
              _getFacilityIcon(facility.type),
              const SizedBox(height: 4),
              Text(
                facility.type.shortName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'LVL ${facility.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ] else ...[
              const Icon(Icons.add_circle_outline, color: Color(0xFF64748B), size: 22),
              const SizedBox(height: 4),
              Text(
                'Slot ${slotIndex + 1}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontFamily: 'monospace'),
              ),
              const Text(
                'Bakante',
                style: TextStyle(color: Color(0xFF475569), fontSize: 8, fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getFacilityIcon(FacilityType type) {
    switch (type) {
      case FacilityType.gulongTarget:
        return const Icon(Icons.sports_mma, color: Color(0xFFEF4444), size: 22);
      case FacilityType.footworkTires:
        return const Icon(Icons.directions_run, color: Color(0xFF38BDF8), size: 22);
      case FacilityType.sparringRing:
        return const Icon(Icons.shield, color: Color(0xFFF59E0B), size: 22);
      case FacilityType.studyDesk:
        return const Icon(Icons.menu_book, color: Color(0xFF8B5CF6), size: 22);
      case FacilityType.bukoStand:
        return const Icon(Icons.local_drink, color: Color(0xFF10B981), size: 22);
    }
  }

  // FIGHTER PROFILE SECTION
  Widget _buildFighterProfileSection(BuildContext context, GameStateProvider state) {
    final f = state.fighter;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(color: const Color(0xFF38BDF8), width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and School Standing
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(Icons.sports_kabaddi, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '${f.gradeLevelDescription} • Edad: ${f.age}',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),

              // Active Style Selector
              PopupMenuButton<FighterStyle>(
                initialValue: f.style,
                onSelected: state.switchStyle,
                color: const Color(0xFF0F172A),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        f.style.displayName,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF38BDF8), size: 16),
                    ],
                  ),
                ),
                itemBuilder: (context) => FighterStyle.values.map((s) {
                  return PopupMenuItem(
                    value: s,
                    child: Text(
                      '${s.displayName} (Lvl ${f.styleMasteries[s] ?? 1})',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ATTRIBUTES BREAKDOWN
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStatBar('LAKAS (POW)', f.power, f.effectivePower, const Color(0xFFEF4444)),
                    const SizedBox(height: 6),
                    _buildStatBar('BILIS (SPD)', f.speed, f.effectiveSpeed, const Color(0xFF38BDF8)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _buildStatBar('DISKARTE (TEC)', f.technique, f.effectiveTechnique, const Color(0xFFEAB308)),
                    const SizedBox(height: 6),
                    _buildStatBar('SALAG (DEF)', f.defense, f.effectiveDefense, const Color(0xFF10B981)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // WEAPONS & GEAR ROW
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hardware, color: Color(0xFFFBBF24), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Baston: ${f.equippedWeapon.name}',
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                Text(
                  'Signature: ${f.style.signatureMove}',
                  style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double base, double effective, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontFamily: 'monospace'),
            ),
            Text(
              effective.toStringAsFixed(1),
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (effective / 60.0).clamp(0.05, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // BOTTOM ACTION BAR
  Widget _buildBottomActionBar(BuildContext context, GameStateProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Color(0xFF475569), width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // TRAIN
          _buildActionButton(
            context,
            title: 'SANAY',
            subtitle: 'Train',
            icon: Icons.fitness_center,
            color: const Color(0xFF38BDF8),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => TrainingModal(gameState: state),
              );
            },
          ),

          // STUDY
          _buildActionButton(
            context,
            title: 'ARAL',
            subtitle: 'Study',
            icon: Icons.menu_book,
            color: const Color(0xFF8B5CF6),
            onTap: () {
              state.performTraining(ActionType.study);
            },
          ),

          // REST
          _buildActionButton(
            context,
            title: 'HINGA',
            subtitle: 'Rest',
            icon: Icons.hotel,
            color: const Color(0xFF06B6D4),
            onTap: () {
              state.performTraining(ActionType.rest);
            },
          ),

          // FRIENDLY SPARRING
          _buildActionButton(
            context,
            title: 'SPAR',
            subtitle: 'Match',
            icon: Icons.sports_kabaddi,
            color: const Color(0xFF10B981),
            onTap: () {
              final opponent = FighterModel.createBertoRival(level: state.year);
              _startMatch(
                player: state.fighter,
                opponent: opponent,
                arenaType: ArenaType.purokLupa,
              );
            },
          ),

          // TOURNAMENTS
          _buildActionButton(
            context,
            title: 'LABAN',
            subtitle: 'Tourney',
            icon: Icons.emoji_events,
            color: const Color(0xFFF59E0B),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => TournamentModal(
                  gameState: state,
                  onStartMatch: (tourney, opp) {
                    final arena = tourney.track == TournamentTrack.schoolTrack
                        ? (tourney.id == 'palarong_pambansa'
                            ? ArenaType.nationalArena
                            : ArenaType.coveredCourt)
                        : ArenaType.purokLupa;

                    _startMatch(
                      player: state.fighter,
                      opponent: opp.toFighterModel(),
                      tournament: tourney,
                      arenaType: arena,
                    );
                  },
                ),
              );
            },
          ),

          // SHOP
          _buildActionButton(
            context,
            title: 'TIANGGE',
            subtitle: 'Shop',
            icon: Icons.shopping_bag,
            color: const Color(0xFFE11D48),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => ShopModal(gameState: state),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
