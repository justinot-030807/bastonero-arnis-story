import 'package:flutter/material.dart';
import '../../models/fighter_model.dart';
import '../../models/tournament_model.dart';
import '../../models/opponent_record_model.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';

class ExpertsAnalysisModal extends StatelessWidget {
  final GameStateProvider gameState;
  final TournamentModel? tournament;
  final TournamentOpponent opponent;
  final VoidCallback onStartFight;
  final VoidCallback onBack;

  const ExpertsAnalysisModal({
    super.key,
    required this.gameState,
    this.tournament,
    required this.opponent,
    required this.onStartFight,
    required this.onBack,
  });

  String _compareRating(double playerVal, double oppVal) {
    final diff = playerVal - oppVal;
    if (diff >= 12.0) return 'Unmatched';
    if (diff >= 4.0) return 'Advantage';
    if (diff <= -12.0) return 'Dismal';
    if (diff <= -4.0) return 'Disadvantage';
    return 'Equal';
  }

  Color _ratingColor(String rating) {
    switch (rating) {
      case 'Unmatched':
        return const Color(0xFF2563EB); // Vibrant Blue
      case 'Advantage':
        return const Color(0xFF16A34A); // Crisp Green
      case 'Equal':
        return const Color(0xFF64748B); // Slate Grey
      case 'Disadvantage':
        return const Color(0xFFE6482E); // Orange Red
      case 'Dismal':
        return const Color(0xFFDC2626); // Dark Red
      default:
        return const Color(0xFF64748B);
    }
  }

  String _generateCoachAdvice(FighterModel player, TournamentOpponent opp) {
    if (player.effectiveSpeed > opp.speed + 3) {
      return 'Lamang tayo sa bilis ng paa! Gamitin ang Iwas at mabilisang counter-strike para mapagod si ${opp.name}!';
    } else if (player.effectivePower > opp.power + 3) {
      return 'Mas mabigat ang ating palo! Pag may bukas, bitawan agad ang BIRA para sa agarang knockout!';
    } else if (player.effectiveDefense > opp.defense + 3) {
      return 'Matibay ang ating salag. Hintayin siyang magkamali bago magpasabog ng diskarte!';
    } else if (player.effectiveTechnique > opp.technique + 3) {
      return 'Mas pino ang ating Anyo at Diskarte. Asintahin ang Sabong clinch lock para disarmahan ang kalaban!';
    } else {
      return 'Halos patas ang inyong lakas at bilis. Bantayan ang timing ng salag at huwag magpadalos-dalos!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = gameState.fighter;
    final h2h = gameState.opponentRecords[opponent.name] ??
        OpponentRecord(
          id: opponent.name,
          name: opponent.name,
          title: opponent.title,
          gymName: opponent.gymName,
          style: opponent.style,
          matchesFought: 0,
          wins: 0,
          losses: 0,
        );

    final hpRating = _compareRating(player.maxHp, opponent.hp);
    final stamRating = _compareRating(player.maxStamina, 100.0);
    final skillRating = _compareRating(player.effectiveTechnique, opponent.technique);
    final punchRating = _compareRating(player.effectivePower, opponent.power);
    final defRating = _compareRating(player.effectiveDefense, opponent.defense);
    final footRating = _compareRating(player.effectiveSpeed, opponent.speed);

    final coachQuote = _generateCoachAdvice(player, opponent);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 440,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFF1A1C2C), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0F172A),
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP HEADER BAR (KAIROSOFT BLUE SKY BANNER)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  ),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF1A1C2C), width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    const PixelSpriteWidget(matrix: PixelArtCatalog.miniTrophy, pixelSize: 1.4),
                    const SizedBox(width: 6),
                    Text(
                      'Yr ${gameState.year} Mn ${gameState.month} Wk ${gameState.week}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    const PixelSpriteWidget(matrix: PixelArtCatalog.miniPeso, pixelSize: 1.4),
                    const SizedBox(width: 4),
                    Text(
                      'P${gameState.pesos}',
                      style: const TextStyle(
                        color: Color(0xFFFDE047),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // SPIRAL-BOUND NOTEBOOK BODY
              Flexible(
                child: Container(
                  color: const Color(0xFFF8FAFC), // Authentic Notebook Off-White Paper
                  padding: const EdgeInsets.fromLTRB(14, 10, 18, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // NOTEBOOK CYAN HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                          ),
                          child: const Text(
                            "Expert's Analysis / Pagsusuri ng Eksperto",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0369A1),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // FIGHTER A VS FIGHTER B TITLE ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              color: const Color(0xFFEF4444),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                opponent.name,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // MINI PREVIEW RING GRAPHIC (FACING OFF)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Player Chibi Avatar + Red Glove/Baston
                              Column(
                                children: [
                                  const PixelSpriteWidget(
                                    matrix: PixelArtCatalog.chibiBayaniIdle,
                                    pixelSize: 1.8,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: const Color(0xFFDC2626),
                                    child: const Text('Red Corner', style: TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace')),
                                  ),
                                ],
                              ),

                              // Center Mini Ring Banner & Stage
                              Column(
                                children: [
                                  const PixelSpriteWidget(
                                    matrix: PixelArtCatalog.miniRing,
                                    pixelSize: 1.6,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: const Color(0xFF0284C7),
                                    child: Text(
                                      tournament?.bracket?.activePlayerMatch?.stageName ?? 'Match Bout',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Opponent Chibi Avatar + Blue Corner
                              Column(
                                children: [
                                  const PixelSpriteWidget(
                                    matrix: PixelArtCatalog.chibiOpponentIdle,
                                    pixelSize: 1.8,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: const Color(0xFF2563EB),
                                    child: const Text('Blue Corner', style: TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // HEAD-TO-HEAD STAT COMPARISON TABLE (IMAGE 2 FORMAT)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Column(
                            children: [
                              _buildComparisonRow(
                                ratingLeft: hpRating,
                                iconMatrix: PixelArtCatalog.miniHeart,
                                statName: 'HP / Tibay',
                                ratingRight: hpRating == 'Advantage' ? 'Disadvantage' : (hpRating == 'Unmatched' ? 'Dismal' : hpRating),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              _buildComparisonRow(
                                ratingLeft: stamRating,
                                iconMatrix: PixelArtCatalog.miniLightning,
                                statName: 'Hangin / Stamina',
                                ratingRight: stamRating == 'Advantage' ? 'Disadvantage' : stamRating,
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              _buildComparisonRow(
                                ratingLeft: skillRating,
                                iconMatrix: PixelArtCatalog.miniBastonIcon,
                                statName: 'Diskarte / Skill',
                                ratingRight: skillRating == 'Advantage' ? 'Disadvantage' : (skillRating == 'Unmatched' ? 'Dismal' : skillRating),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              _buildComparisonRow(
                                ratingLeft: punchRating,
                                iconMatrix: PixelArtCatalog.miniMuscle,
                                statName: 'Lakas / Power',
                                ratingRight: punchRating == 'Advantage' ? 'Disadvantage' : (punchRating == 'Unmatched' ? 'Dismal' : punchRating),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              _buildComparisonRow(
                                ratingLeft: defRating,
                                iconMatrix: PixelArtCatalog.miniTrunks,
                                statName: 'Salag / Defense',
                                ratingRight: defRating == 'Advantage' ? 'Disadvantage' : (defRating == 'Unmatched' ? 'Dismal' : defRating),
                              ),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              _buildComparisonRow(
                                ratingLeft: footRating,
                                iconMatrix: PixelArtCatalog.miniShoe,
                                statName: 'Bilis / Footwork',
                                ratingRight: footRating == 'Advantage' ? 'Disadvantage' : (footRating == 'Unmatched' ? 'Dismal' : footRating),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // HEAD-TO-HEAD DOSSIER RECORD
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const PixelSpriteWidget(matrix: PixelArtCatalog.miniPrestige, pixelSize: 1.2),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'H2H: ${h2h.recordString} (${h2h.matchesFought}x nakatapat) | Gym: ${opponent.gymName}',
                                  style: const TextStyle(
                                    color: Color(0xFF92400E),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // COACH KANOR'S SPEECH BUBBLE (IMAGE 2 BOTTOM CALLOUT)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const PixelSpriteWidget(
                              matrix: PixelArtCatalog.coachKanorPortrait,
                              pixelSize: 1.8,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFFCBD5E1),
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Coach Kanor: "$coachQuote"',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 9,
                                    fontFamily: 'monospace',
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // BOTTOM ACTIONS BAR: BUMALIK (BACK) & SULONG! LABAN (NEXT / FIGHT)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    top: BorderSide(color: Color(0xFF1A1C2C), width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: RetroButton(
                        height: 38,
                        color: const Color(0xFF475569),
                        onTap: onBack,
                        child: const Text(
                          'BUMALIK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: RetroButton(
                        height: 38,
                        color: const Color(0xFFE6482E),
                        onTap: onStartFight,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PixelSpriteWidget(matrix: PixelArtCatalog.miniBastonIcon, pixelSize: 1.4),
                            SizedBox(width: 6),
                            Text(
                              'SULONG! LABAN NA!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required String ratingLeft,
    required List<String> iconMatrix,
    required String statName,
    required String ratingRight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          // Left Rating (Player)
          SizedBox(
            width: 85,
            child: Text(
              ratingLeft,
              style: TextStyle(
                color: _ratingColor(ratingLeft),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),

          // Center Stat Icon + Name
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PixelSpriteWidget(matrix: iconMatrix, pixelSize: 1.3),
                const SizedBox(width: 6),
                Text(
                  statName,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // Right Rating (Opponent)
          SizedBox(
            width: 85,
            child: Text(
              ratingRight,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _ratingColor(ratingRight),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
