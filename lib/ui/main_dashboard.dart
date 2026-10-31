import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fighter_model.dart';
import '../models/tournament_model.dart';
import '../providers/game_state_provider.dart';
import '../game/arnis_match_game.dart';
import '../game/components/arena_component.dart';
import 'retro_ui.dart';
import 'title_screen.dart';
import 'components/live_bakuran_camp.dart';
import 'overlays/match_hud_overlay.dart';
import 'overlays/timing_minigame_overlay.dart';
import 'overlays/match_result_overlay.dart';
import 'overlays/estudyante_modal.dart';
import 'overlays/training_modal.dart';
import 'overlays/tournament_modal.dart';
import 'overlays/tournament_bracket_modal.dart';
import 'overlays/experts_analysis_modal.dart';
import 'overlays/gym_builder_modal.dart';
import 'overlays/monthly_summary_modal.dart';
import 'overlays/event_dialog_modal.dart';
import 'overlays/recruit_dialog_modal.dart';
import 'overlays/graduation_modal.dart';
import '../domain/systems/recruitment_system.dart';
import 'overlays/story_dialog_modal.dart';
import 'overlays/tiangge_modal.dart';

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
    TournamentOpponent? tournamentOpponent,
    ArenaType arenaType = ArenaType.purokLupa,
  }) {
    final state = Provider.of<GameStateProvider>(context, listen: false);
    final game = ArnisMatchGame(
      playerFighter: player,
      opponentFighter: opponent,
      playerStudent: state.activeStudent,
      tournament: tournament,
      arenaType: arenaType,
      onMatchEnded: (won, maxDamage) {
        final provider = Provider.of<GameStateProvider>(context, listen: false);
        if (tournament != null && tournamentOpponent != null) {
          provider.handleBracketMatchResult(
            tournament: tournament,
            currentOpponent: tournamentOpponent,
            won: won,
            maxDamage: maxDamage,
          );
        } else if (tournament != null) {
          provider.completeTournament(tournament, won);
        } else {
          provider.advanceOneWeek(
            actionSummary: won
                ? '[PANALO] Tagumpay sa Friendly Sparring! +XP!'
                : '[SPARRING] Natapos ang sparring. May natutunang bagong diskarte!',
          );
        }
      },
    );

    setState(() {
      _activeGame = game;
    });
  }

  void _launchTournamentBout(TournamentModel tourney, TournamentOpponent opp) {
    final state = Provider.of<GameStateProvider>(context, listen: false);
    final arena = tourney.track == TournamentTrack.schoolTrack
        ? (tourney.id == 'palarong_pambansa'
            ? ArenaType.nationalArena
            : ArenaType.coveredCourt)
        : ArenaType.purokLupa;
    _startMatch(
      player: state.fighter,
      opponent: opp.toFighterModel(),
      tournament: tourney,
      tournamentOpponent: opp,
      arenaType: arena,
    );
  }

  void _openBracketModal(TournamentModel tourney) {
    showDialog(
      context: context,
      builder: (ctx) => TournamentBracketModal(
        gameState: Provider.of<GameStateProvider>(context, listen: false),
        tournament: tourney,
        onOpenAnalysis: (t, opp) {
          Navigator.of(ctx).pop();
          _openAnalysisModal(t, opp);
        },
        onStartMatch: (t, opp) {
          Navigator.of(ctx).pop();
          _launchTournamentBout(t, opp);
        },
        onBack: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _openAnalysisModal(TournamentModel? tourney, TournamentOpponent opp) {
    showDialog(
      context: context,
      builder: (ctx) => ExpertsAnalysisModal(
        gameState: Provider.of<GameStateProvider>(context, listen: false),
        tournament: tourney,
        opponent: opp,
        onBack: () => Navigator.of(ctx).pop(),
        onStartFight: () {
          Navigator.of(ctx).pop();
          if (tourney != null) {
            _launchTournamentBout(tourney, opp);
          } else {
            final state = Provider.of<GameStateProvider>(context, listen: false);
            _startMatch(
              player: state.fighter,
              opponent: opp.toFighterModel(),
              tournamentOpponent: opp,
              arenaType: ArenaType.purokLupa,
            );
          }
        },
      ),
    );
  }

  void _exitMatch() {
    setState(() {
      _activeGame = null;
    });
  }

  void _openSystemMenu(BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: RetroBox(
          width: 320,
          title: 'SYSTEM MENYU',
          titleTrailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(ctx).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          backgroundColor: const Color(0xFF0F172A),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RetroButton(
                color: const Color(0xFF16A34A),
                onTap: () {
                  gameState.saveGame();
                  Navigator.of(ctx).pop();
                },
                child: const Text('MANUAL SAVE NGAYON', style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
              ),
              const SizedBox(height: 10),
              RetroButton(
                color: const Color(0xFF0284C7),
                onTap: () {
                  Navigator.of(ctx).pop();
                  gameState.returnToTitle();
                },
                child: const Text('BUMALIK SA TITLE SCREEN', style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditProfileDialog(BuildContext context, GameStateProvider gameState) {
    final nameCtrl = TextEditingController(text: gameState.fighter.name);
    final nickCtrl = TextEditingController(text: gameState.fighter.nickname);
    final gymCtrl = TextEditingController(text: gameState.fighter.gymName);

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: RetroBox(
            width: 360,
            title: 'I-EDIT ANG PROFILE NG ARNISADOR',
            titleTrailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: () => Navigator.of(ctx).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            backgroundColor: const Color(0xFF0F172A),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pangalan ng Arnisador:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alias / Palayaw (Nickname):',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: TextField(
                    controller: nickCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pangalan ng Camp / Gym:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: TextField(
                    controller: gymCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),
                const SizedBox(height: 16),
                RetroButton(
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    final n = nameCtrl.text.trim();
                    final k = nickCtrl.text.trim();
                    final g = gymCtrl.text.trim();
                    if (n.isNotEmpty) gameState.fighter.name = n;
                    if (k.isNotEmpty) gameState.fighter.nickname = k;
                    if (g.isNotEmpty) gameState.fighter.gymName = g;
                    gameState.saveGame();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('I-SAVE ANG PAGBABAGO', style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, _) {
        // If on Title Screen
        if (gameState.isInTitleScreen) {
          return const TitleScreen();
        }

        // If in Active Combat Match
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

        // Main Kairosoft Live Gym View
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // 1. TOP HUD (CALENDAR, PESOS, ACADEMICS, NUTRITION BUFFS)
                    _buildTopHud(context, gameState),

                    // 2. KAIROSOFT RETRO TICKER
                    _buildTicker(gameState),

                    // 3. MAIN LIVE CAMP & STATS
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ACTIVE SYNERGIES STRIP
                            if (gameState.activeSynergies.isNotEmpty)
                              _buildSynergyStrip(gameState),

                            // LIVE BAKURAN CUTAWAY VIEW
                            LiveBakuranCampView(
                              gameState: gameState,
                              onSlotTapped: (slotIndex) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => GymBuilderModal(
                                    gameState: gameState,
                                    slotIndex: slotIndex,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            // FIGHTER ATTRIBUTES & PROFILE
                            _buildFighterProfileSection(context, gameState),
                          ],
                        ),
                      ),
                    ),

                    // 4. 6-BUTTON PIXEL BOTTOM BAR + FLOATING MENU
                    _buildBottomActionBar(context, gameState),
                  ],
                ),
              ),

              // STORY EVENT DIALOG MODAL (IF ACTIVE)
              if (gameState.activeDialogueEvent != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: StoryDialogModal(
                    event: gameState.activeDialogueEvent!,
                    onDismiss: gameState.dismissActiveDialogue,
                  ),
                ),

              // MONTHLY FINANCIAL SUMMARY MODAL (IF TRIGGERED)
              if (gameState.shouldShowMonthlySummary && gameState.lastMonthlyLedger != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: MonthlySummaryModal(
                    ledger: gameState.lastMonthlyLedger!,
                    onDismiss: gameState.dismissMonthlySummary,
                  ),
                ),

              // RANDOM EVENT MODAL
              if (gameState.activeEventDialog != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: EventDialogModal(
                    event: gameState.activeEventDialog!,
                    onResolve: gameState.resolveEventChoice,
                  ),
                ),

              // WALK-IN / SCHOLARSHIP RECRUIT MODAL
              if (gameState.activeRecruitDialog != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: RecruitDialogModal(
                    candidate: gameState.activeRecruitDialog!,
                    canAfford: gameState.pesos >= gameState.activeRecruitDialog!.fee,
                    hasSpace: RecruitmentSystem.hasCapacity(gameState.camp),
                    onAccept: gameState.enrollRecruitCandidate,
                    onDecline: gameState.declineRecruitCandidate,
                  ),
                ),

              // GRADUATION / ALUMNI SELECTION MODAL
              if (gameState.activeGraduationDialog != null)
                Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: GraduationModal(
                    candidate: gameState.activeGraduationDialog!,
                    onChooseRole: gameState.resolveGraduationRole,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1A1C2C), width: 3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Calendar Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFFF4B41B), width: 1.5),
                ),
                child: Text(
                  'Y${state.year} Wk${state.week} - ${state.currentMonthName.split(' ').first}',
                  style: const TextStyle(
                    color: Color(0xFFFDE047),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

              // Summer Break Tag
              if (state.isSummerBreak) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C),
                    border: Border.all(color: const Color(0xFFFDBA74), width: 1),
                  ),
                  child: const Text(
                    'BAKASYON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 5),

              // Speed Controls: [||] [1x] [2x] [4x]
              _buildSpeedButton(state, GameSpeed.pause, '||'),
              const SizedBox(width: 2),
              _buildSpeedButton(state, GameSpeed.normal1x, '1x'),
              const SizedBox(width: 2),
              _buildSpeedButton(state, GameSpeed.fast2x, '2x'),
              const SizedBox(width: 2),
              _buildSpeedButton(state, GameSpeed.fast4x, '4x'),

              const Spacer(),

              // Currency with Low Money Warning Banner
              Row(
                children: [
                  const PixelSpriteWidget(matrix: PixelArtCatalog.miniPeso, pixelSize: 1.6),
                  const SizedBox(width: 3),
                  if (state.isLowMoney)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        border: Border.all(color: const Color(0xFFF87171), width: 1),
                      ),
                      child: Text(
                        'KAPOS P${state.pesos}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    )
                  else
                    Text(
                      'P${state.pesos}',
                      style: const TextStyle(
                        color: Color(0xFFFDE047),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  if (state.totalPassiveWeeklyPesos > 0)
                    Text(
                      ' (+P${state.totalPassiveWeeklyPesos})',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 8, fontFamily: 'monospace'),
                    ),
                ],
              ),

              // Active Bailout Tag
              if (state.hasActiveBailout) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                  ),
                  child: Text(
                    'UTANG ${state.bailoutWeeksRemaining}w',
                    style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
              ],

              const SizedBox(width: 8),

              // Prestige
              Row(
                children: [
                  const PixelSpriteWidget(matrix: PixelArtCatalog.miniPrestige, pixelSize: 1.6),
                  const SizedBox(width: 3),
                  Text(
                    '${state.prestige}',
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Week Progress Indicator
          if (state.speed != GameSpeed.pause) ...[
            const SizedBox(height: 3),
            ClipRRect(
              child: LinearProgressIndicator(
                value: state.weekProgress,
                minHeight: 2,
                backgroundColor: const Color(0xFF0F172A),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
              ),
            ),
          ],

          const SizedBox(height: 6),

          // STAMINA & ACADEMICS ROW
          Row(
            children: [
              // Hangin (Stamina)
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    const PixelSpriteWidget(matrix: PixelArtCatalog.miniWind, pixelSize: 1.4),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PixelBar(
                        current: fighter.stamina,
                        max: fighter.maxStamina,
                        fillColor: const Color(0xFF38BDF8),
                        totalSegments: 10,
                        height: 8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${fighter.stamina.toInt()}',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Academics Grado
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    const PixelSpriteWidget(matrix: PixelArtCatalog.iconAral, pixelSize: 0.9),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      color: isVarsityOk ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      child: Text(
                        '${fighter.academics.toStringAsFixed(1)}% (${isVarsityOk ? "Varsity" : "Suspended"})',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ACTIVE NUTRITIONAL BUFF BADGES (IF ANY)
          if (state.activeBuffs.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'BUFF: ',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'monospace'),
                ),
                for (final buff in state.activeBuffs) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: const Color(0xFF16A34A),
                    child: Text(
                      '${buff.name} (${buff.remainingWeeks}w)',
                      style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedButton(GameStateProvider state, GameSpeed speedMode, String label) {
    final isActive = state.speed == speedMode;
    return GestureDetector(
      onTap: () => state.setSpeed(speedMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
          border: Border.all(
            color: isActive ? const Color(0xFF38BDF8) : const Color(0xFF475569),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 7,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // TICKER
  Widget _buildTicker(GameStateProvider state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
      child: Row(
        children: [
          Container(width: 4, height: 4, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              state.recentLog,
              style: const TextStyle(
                color: Color(0xFFE0F2FE),
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(color: const Color(0xFFF4B41B), width: 1.5),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: state.activeSynergies.map((s) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: const Color(0xFF0F172A),
            child: Text(
              '[COMBO] ${s.title}',
              style: const TextStyle(color: Color(0xFFFDE047), fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          );
        }).toList(),
      ),
    );
  }

  // FIGHTER ATTRIBUTES SECTION
  Widget _buildFighterProfileSection(BuildContext context, GameStateProvider state) {
    final f = state.fighter;

    return RetroBox(
      title: 'FIGHTER PROFILE & DISKARTE',
      backgroundColor: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              const PixelSpriteWidget(
                matrix: PixelArtCatalog.bayaniPortrait,
                pixelSize: 2.2,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${f.name} "${f.nickname}"',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _openEditProfileDialog(context, state),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              border: Border.all(color: const Color(0xFFF4B41B), width: 1),
                            ),
                            child: const Text(
                              'I-EDIT',
                              style: TextStyle(color: Color(0xFFFDE047), fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => EstudyanteModal(gameState: state),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              'ROSTER (${state.students.length})',
                              style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Gym: ${f.gymName} | ${f.gradeLevelDescription} (${f.age} y/o)',
                      style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 8.5, fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Coach: ${f.coachName} (${f.coachTitle})',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 8.5, fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Perk: ${f.coachPerk}',
                      style: const TextStyle(color: Color(0xFFFACC15), fontSize: 8, fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Style Dropdown
              PopupMenuButton<FighterStyle>(
                initialValue: f.style,
                onSelected: state.switchStyle,
                color: const Color(0xFF0F172A),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        f.style.displayName,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF38BDF8), size: 14),
                    ],
                  ),
                ),
                itemBuilder: (context) => FighterStyle.values.map((s) {
                  return PopupMenuItem(
                    value: s,
                    child: Text(
                      '${s.displayName} (Lvl ${f.styleMasteries[s] ?? 1})',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ATTRIBUTES WITH PIXEL PROGRESS BARS
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('LAKAS', f.effectivePower, const Color(0xFFDC2626)),
                    const SizedBox(height: 6),
                    _buildStatRow('BILIS', f.effectiveSpeed, const Color(0xFF38BDF8)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('DISKARTE', f.effectiveTechnique, const Color(0xFFF4B41B)),
                    const SizedBox(height: 6),
                    _buildStatRow('SALAG', f.effectiveDefense, const Color(0xFF4ADE80)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // WEAPON & GEAR READOUT
          Container(
            padding: const EdgeInsets.all(6),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Baston: ${f.equippedWeapon.name}',
                  style: const TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontFamily: 'monospace'),
                ),
                Text(
                  'Move: ${f.style.signatureMove}',
                  style: const TextStyle(color: Color(0xFFE6482E), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 8, fontFamily: 'monospace')),
            Text(val.toStringAsFixed(1), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 2),
        PixelBar(
          current: val,
          max: 60.0,
          fillColor: color,
          totalSegments: 10,
          height: 6,
        ),
      ],
    );
  }

  // 6-BUTTON PIXEL BOTTOM BAR + FLOATING SYSTEM MENU
  Widget _buildBottomActionBar(BuildContext context, GameStateProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Color(0xFF1A1C2C), width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            title: 'SANAY',
            subtitle: 'Train',
            matrix: PixelArtCatalog.iconSanay,
            color: const Color(0xFF38BDF8),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => TrainingModal(gameState: state),
              );
            },
          ),
          _buildActionButton(
            title: 'ARAL',
            subtitle: 'Study',
            matrix: PixelArtCatalog.iconAral,
            color: const Color(0xFF8B5CF6),
            onTap: () => state.performTraining(ActionType.study),
          ),
          _buildActionButton(
            title: 'HINGA',
            subtitle: 'Rest',
            matrix: PixelArtCatalog.iconHinga,
            color: const Color(0xFF06B6D4),
            onTap: () => state.performTraining(ActionType.rest),
          ),
          _buildActionButton(
            title: 'SPAR',
            subtitle: 'Match',
            matrix: PixelArtCatalog.iconSpar,
            color: const Color(0xFF10B981),
            onTap: () {
              final opp = TournamentOpponent(
                name: 'Berto Batuta',
                title: 'Purok Heavy Hitter',
                gymName: 'Ilaya Bakbakan Gym',
                officialRecord: '10-2-1',
                hp: 110.0 + (state.year * 15),
                power: 18.0 + (state.year * 3),
                speed: 13.0 + (state.year * 2),
                technique: 12.0 + (state.year * 2),
                defense: 12.0 + (state.year * 2.5),
                style: FighterStyle.soloBaston,
                weapon: WeaponItem.bahi,
                dialogue: 'Handa ka na ba para sa friendly sparring sa bakuran?',
              );
              _openAnalysisModal(null, opp);
            },
          ),
          _buildActionButton(
            title: 'LABAN',
            subtitle: 'Tourney',
            matrix: PixelArtCatalog.iconLaban,
            color: const Color(0xFFF4B41B),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => TournamentModal(
                  gameState: state,
                  onOpenBracket: (tourney) => _openBracketModal(tourney),
                  onOpenAnalysis: (tourney, opp) => _openAnalysisModal(tourney, opp),
                  onStartMatch: (tourney, opp) => _launchTournamentBout(tourney, opp),
                ),
              );
            },
          ),
          _buildActionButton(
            title: 'TIANGGE',
            subtitle: 'Shop',
            matrix: PixelArtCatalog.iconTiangge,
            color: const Color(0xFFE6482E),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => TianggeModal(gameState: state),
              );
            },
          ),
          _buildActionButton(
            title: 'MENYU',
            subtitle: 'System',
            matrix: PixelArtCatalog.iconSettings,
            color: const Color(0xFF64748B),
            onTap: () => _openSystemMenu(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required List<String> matrix,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelSpriteWidget(matrix: matrix, pixelSize: 1.1),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            Text(subtitle, style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 7, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}
